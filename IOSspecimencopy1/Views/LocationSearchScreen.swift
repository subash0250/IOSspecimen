//
//  LocationSearchScreen.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-15.
//

import SwiftUI

import CoreLocation

struct LocationSearchScreen: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var isLoading = false

    let onSelectLocation: (String, Double, Double) -> Void

    var body: some View {
        VStack {
            TextField("Search for a location...", text: $searchQuery, onCommit: fetchLocations)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if isLoading {
                ProgressView("Searching...")
            } else {
                List(searchResults, id: \.name) { placemark in
                    Button(action: {
                        if let name = placemark.locality,
                           let lat = placemark.location?.coordinate.latitude,
                           let lon = placemark.location?.coordinate.longitude {
                            onSelectLocation(name, lat, lon)
                            // Dismiss the screen
                            dismiss()
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text(placemark.name ?? "Unknown")
                                .font(.headline)
                            Text(placemark.locality ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Select Location")
    }

    // MARK: - Fetch Locations using CoreLocation

    func fetchLocations() {
        guard !searchQuery.isEmpty else { return }

        isLoading = true
        CLGeocoder().geocodeAddressString(searchQuery) { placemarks, error in
            isLoading = false
            if let error = error {
                print("Error fetching locations: \(error.localizedDescription)")
                return
            }
            searchResults = placemarks ?? []
        }
    }

    // Helper to dismiss the view
    private func dismiss() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
