//
//  MovieFlixSwiftUIApp.swift
//  MovieFlixSwiftUI
//
//  Created by Angelos Staboulis on 15/9/25.
//

import SwiftUI

@main
struct MovieFlixSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(apiKey: "d8d8c423", isSearching: false)
        }
    }
}
