//
//  Config.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation

// All constants in one place, so they are easy to change.
enum Config {
    // Put your real NASA key here (DEMO_KEY works for quick tests only)
    static let nasaAPIKey = "DEMO_KEY"

    static let apodBaseURL = "https://api.nasa.gov/planetary/apod"

    // Earliest date NASA has a picture for
    static let earliestDate = "1995-06-16"

    // How many past days the gallery shows
    static let galleryDays = 10
}
