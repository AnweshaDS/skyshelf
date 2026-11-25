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
        case .badKey:       return "The NASA API key is not valid. Check Config.swift."
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
}

// Talks to the NASA APOD API using URLSession and async/await
struct APODService {

    // One day. date == nil means "NASA's today".
    func fetchDay(date: String?) async throws -> APODItem {
        var extra: [URLQueryItem] = []
        if let date = date {
            extra.append(URLQueryItem(name: "date", value: date))
        }
        let data = try await load(extra)
        do {
            return try JSONDecoder().decode(APODItem.self, from: data)
        } catch {
            throw APODError.decoding
        }
    }

    // A range of days. NASA returns a JSON ARRAY.
    func fetchRange(start: String, end: String) async throws -> [APODItem] {
        let extra = [
            URLQueryItem(name: "start_date", value: start),
            URLQueryItem(name: "end_date", value: end)
        ]
        let data = try await load(extra)
        do {
            return try JSONDecoder().decode([APODItem].self, from: data)
        } catch {
            throw APODError.decoding
        }
    }

    // Today's picture. NASA's day follows US time, so in Bangladesh
    // today's picture may not exist yet. Then we try yesterday, then the day before.
    func fetchToday() async throws -> APODItem {
        do {
            return try await fetchDay(date: nil)
        } catch let error as APODError {
            // Going back a day will not fix these, so stop here
            if error == .noInternet || error == .rateLimit || error == .badKey {
                throw error
            }
        }

        var lastError: Error = APODError.server
        for daysBack in 1...2 {
            let day = DateHelper.addDays(-daysBack, to: DateHelper.string(from: Date()))
            do {
                return try await fetchDay(date: day)
            } catch {
                lastError = error
            }
        }
        throw lastError
    }

    // Builds the URL, calls NASA and checks the status code
    private func load(_ extra: [URLQueryItem]) async throws -> Data {
        var components = URLComponents(string: Config.apodBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: Config.nasaAPIKey),
            URLQueryItem(name: "thumbs", value: "true")
        ] + extra

        guard let url = components?.url else {
            throw APODError.badDate
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200:      return data
                case 400:      throw APODError.badDate
                case 403:      throw APODError.badKey
                case 404:      throw APODError.notPublished
                case 429:      throw APODError.rateLimit
                default:       throw APODError.server
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
