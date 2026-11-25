//
//  HomeView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var auth: AuthManager

    // Today's picture and the recent gallery
    @State private var today: APODItem?
    @State private var recent: [APODItem] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    // Date picker section
    @State private var selectedDate = Date()
    @State private var pickedItem: APODItem?
    @State private var showPicked = false
    @State private var isFetchingDate = false
    @State private var dateError = ""

    private let service = APODService()

    // Earliest date the DatePicker allows
    private var earliestDate: Date {
        return DateHelper.date(from: Config.earliestDate) ?? Date()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    if isLoading && today == nil {
                        ProgressView("Loading today's picture...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    }

                    if !errorMessage.isEmpty {
                        errorBox
                    }

                    if let item = today {
                        todayCard(item)
                    }

                    datePickerSection

                    // Recent gallery: one row per day, each opens DetailView
                    if !recent.isEmpty {
                        Text("Recent pictures")
                            .font(.headline)

                        ForEach(recent) { item in
                            NavigationLink(destination: DetailView(item: item)) {
                                APODRowView(item: item)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("SkyShelf")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        auth.signOut()
                    }
                }
            }
            // Opens DetailView after the "View" button finds a picture
            .navigationDestination(isPresented: $showPicked) {
                if let item = pickedItem {
                    DetailView(item: item)
                }
            }
            .onAppear {
                if today == nil {
                    loadHome()
                }
            }
        }
    }

    // Big card for today's picture
    private func todayCard(_ item: APODItem) -> some View {
        NavigationLink(destination: DetailView(item: item)) {
            VStack(alignment: .leading, spacing: 8) {
                Text("PICTURE OF THE DAY")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)

                APODImageView(url: item.displayImageURL, height: 240)

                Text(item.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                HStack {
                    Text(item.date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !item.isImage {
                        Label("Video", systemImage: "play.circle")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    // Error message with a Retry button
    private var errorBox: some View {
        VStack(spacing: 8) {
            Text(errorMessage)
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            Button("Retry") {
                loadHome()
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }

    // DatePicker + View button
    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Browse by date")
                .font(.headline)

            DatePicker("Pick a date",
                       selection: $selectedDate,
                       in: earliestDate...Date(),
                       displayedComponents: .date)

            if !dateError.isEmpty {
                Text(dateError)
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            Button {
                viewSelectedDate()
            } label: {
                HStack {
                    if isFetchingDate {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("View")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isFetchingDate)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    // Load today's picture, then the 10 days before it
    @MainActor
    func loadHome() {
        isLoading = true
        errorMessage = ""
        Task {
            do {
                let latest = try await service.fetchToday()
                today = latest

                // The gallery is the days BEFORE today's picture
                let end = DateHelper.addDays(-1, to: latest.date)
                let start = DateHelper.addDays(-Config.galleryDays, to: latest.date)
                let items = try await service.fetchRange(start: start, end: end)

                // Newest first (dates sort correctly as text)
                recent = items.sorted { $0.date > $1.date }
            } catch let error as APODError {
                errorMessage = error.message
            } catch {
                errorMessage = "Something went wrong."
            }
            isLoading = false
        }
    }

    // Load the picture for the date chosen in the DatePicker
    @MainActor
    func viewSelectedDate() {
        isFetchingDate = true
        dateError = ""
        Task {
            do {
                let text = DateHelper.string(from: selectedDate)
                pickedItem = try await service.fetchDay(date: text)
                showPicked = true
            } catch let error as APODError {
                dateError = error.message
            } catch {
                dateError = "Something went wrong."
            }
            isFetchingDate = false
        }
    }
}
