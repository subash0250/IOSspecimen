////
////  LocationSearchView.swift
////  IOSspecimencopy1
////
////  Created by Subash Gaddam on 2024-10-15.
////
//
//import SwiftUI
//import MapKit
//
//struct LocationSearchView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var searchText: String = ""
//    @State private var locations: [MKLocalSearchCompletion] = []
//    var onSelectLocation: (String, Double, Double) -> Void
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Search for a location", text: $searchText, onCommit: {
//                    searchLocations()
//                })
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//                List(locations, id: \.self) { location in
//                    Button(action: {
//                        selectLocation(location)
//                    }) {
//                        Text(location.title)
//                    }
//                }
//            }
//            .navigationTitle("Select Location")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//    
//    private func searchLocations() {
//        let searchRequest = MKLocalSearch.Request()
//        searchRequest.naturalLanguageQuery = searchText
//        
//        let search = MKLocalSearch(request: searchRequest)
//        search.start { response, error in
//            guard let response = response else { return }
//            self.locations = response.mapItems.map { $0.placemark }
//        }
//    }
//
//    private func selectLocation(_ location: MKLocalSearchCompletion) {
//        let selectedLocation = location.title
//        let latitude = location.coordinate.latitude
//        let longitude = location.coordinate.longitude
//
//        // Call the onSelectLocation closure to pass back the selected location
//        onSelectLocation(selectedLocation, latitude, longitude)
//        
//        // Dismiss the view
//        presentationMode.wrappedValue.dismiss()
//    }
//}
//
//struct LocationSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationSearchView(onSelectLocation: { _, _, _ in })
//    }
//}
