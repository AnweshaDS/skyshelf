//
//  DetailView.swift
//  SkyShelf
//
//  Created by macos on 25/11/26.
//

import SwiftUI

struct DetailView: View {
    let item: APODItem

    var body: some View {
        VStack(spacing: 12) {
            Text(item.title).font(.title2)
            Text(item.date)
        }
        .padding()
    }
}
