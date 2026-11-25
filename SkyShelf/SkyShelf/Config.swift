//
//  Config.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import Foundation

// All constants in one place, so they are easy to change.
enum Config {
    // New NASA Science APOD endpoint (no API key needed)
    static let apodBaseURL = "https://science.nasa.gov/wp-json/wp/v2/apod-basic"

    // Earliest date NASA has a picture for
    static let earliestDate = "1995-06-16"

    // How many past days the gallery shows
    static let galleryDays = 10
}
