//
//  APODService.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation

// The kinds of things that can go wrong, each with a message for the user
enum APODError: Error {
    case noInternet
    case rateLimit
    case badKey
    case badDate
    case notPublished
    case server
    case decoding

    var message: String {
        switch self {
        case .noInternet:   return "No internet connection. Check your network and try again."
        case .rateLimit:    return "Too many requests to NASA. Please wait a while and retry."
        case .badKey:       return "NASA refused the request. Please try again later."
        case .badDate:      return "That date is not valid. Pick a date from 1995-06-16 up to today (US time)."
        case .notPublished: return "NASA has no picture for this date yet."
        case .server:       return "NASA server problem. Please try again later."
        case .decoding:     return "Could not read the data from NASA."
        }
    }
}

// Small helper to convert between Date and "yyyy-MM-dd" text
enum DateHelper {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()

    static func string(from date: Date) -> String {
        return formatter.string(from: date)
    }

    static func date(from text: String) -> Date? {
        return formatter.date(from: text)
    }

    // "2026-11-13" plus -1 day gives "2026-11-12"
    static func addDays(_ days: Int, to text: String) -> String {
        guard let date = formatter.date(from: text),
              let moved = Calendar.current.date(byAdding: .day, value: days, to: date) else {
            return text
        }
        return formatter.string(from: moved)
    }

    // Number of days from the first date to the second date.
    // ("2026-11-20", "2026-11-25") gives 5
    static func daysBetween(_ from: String, _ to: String) -> Int {
        guard let a = formatter.date(from: from),
              let b = formatter.date(from: to) else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: a, to: b).day ?? 0
    }
}

// Talks to the NASA APOD API using URLSession and async/await.
// The new API lists pictures newest first and works in pages:
// page 1 = newest picture, page 2 = the day before, and so on.
struct APODService {

    // The newest picture NASA has published
    func fetchToday() async throws -> APODItem {
        let items = try await fetchPage(page: 1, perPage: 1)
        guard let latest = items.first else {
            throw APODError.notPublished
        }
        return latest
    }

    // One day. date == nil means "the newest picture".
    func fetchDay(date: String?) async throws -> APODItem {
        let latest = try await fetchToday()

        // No date asked, or the newest day: done
        guard let target = date, target != latest.date else {
            return latest
        }

        // A date after the newest picture does not exist yet
        // (dates in "yyyy-MM-dd" text sort in date order)
        if target > latest.date {
            throw APODError.notPublished
        }

        // Pages go back one day at a time, so guess the page from the day count,
        // then fix the guess using the date we actually got back.
        var page = DateHelper.daysBetween(target, latest.date) + 1

        for _ in 0..<5 {
            let items = try await fetchPage(page: page, perPage: 1)
            guard let item = items.first else {
                throw APODError.notPublished
            }
            if item.date == target {
                return item
            }
            // item newer than the target gives a positive number (go further back)
            page += DateHelper.daysBetween(target, item.date)
            if page < 1 {
                throw APODError.notPublished
            }
        }
        throw APODError.notPublished
    }

    // A range of days, newest first. One request for the recent days,
    // then we keep only the dates between start and end.
    func fetchRange(start: String, end: String) async throws -> [APODItem] {
        let today = DateHelper.string(from: Date())
        let count = min(100, max(DateHelper.daysBetween(start, today) + 2, 1))
        let items = try await fetchPage(page: 1, perPage: count)
        return items.filter { $0.date >= start && $0.date <= end }
    }

    // Asks NASA for one page of pictures and decodes the JSON ARRAY
    private func fetchPage(page: Int, perPage: Int) async throws -> [APODItem] {
        var components = URLComponents(string: Config.apodBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page))
        ]
        guard let url = components?.url else {
            throw APODError.badDate
        }

        let data = try await load(url)
        do {
            return try JSONDecoder().decode([APODItem].self, from: data)
        } catch {
            throw APODError.decoding
        }
    }

    // Calls NASA and checks the status code
    private func load(_ url: URL) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200:       return data
                case 400, 404:  throw APODError.notPublished   // page or day does not exist
                case 403:       throw APODError.badKey
                case 429:       throw APODError.rateLimit
                default:        throw APODError.server
                }
            }
            return data
        } catch let error as APODError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost:
                throw APODError.noInternet
            default:
                throw APODError.server
            }
        } catch {
            throw APODError.server
        }
    }
}
