import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct HomeMap: View {
    @State private var annotations: [CustomAnnotation] = getAnnotations()  // Store original annotations
    @State private var filteredAnnotations: [CustomAnnotation] = [] // Store filtered annotations
    @State private var selectedTag: String = ""  // Track selected filter
    @State private var formIsOpen: Bool = false
    
    var body: some View {
        HStack {
            searchBar // Display the search bar
            uploadTab // Display the upload button
        }
        
        VStack {
            userMap // Display the map
        }
        
        Spacer() // Push the filters to the bottom
        
        filters // Display the filters for accessibility features
    }
    
    private var userMap: some View {
        VStack {
            Map(annotations: filteredAnnotations.isEmpty ? annotations : filteredAnnotations) // Use filtered annotations if available
                .frame(height: 600) // Set a height for the map view
        }
    }
    
    private var searchBar: some View {
        VStack {
            @State var searchText: String = ""
            TextField("Search", text: $searchText)
                .padding(.horizontal, 30) // Additional padding on the sides
                .padding(.vertical, 8) // Additional padding on the top and bottom
                .multilineTextAlignment(.leading)
                .font(.title)
        }
    }
    
    private var uploadTab: some View {
        VStack {
            Button {
                formIsOpen = true
            } label: {
                Image(systemName: "plus.app")
            }.uploadButtonStyle()
                .sheet(isPresented: $formIsOpen) {
                    LocationUploadForm()
                }
        }
    }
    
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("🪐 All") {
                    filterAnnotations(by:"")
                }
                .filterButtonStyle()
                
                Button("🛗 Elevator") {
                    filterAnnotations(by: "Elevator") // Filter by tag
                }
                .filterButtonStyle()
                
                Button("📐 Ramp") {
                    filterAnnotations(by: "Ramps") // Filter by tag
                }
                .filterButtonStyle()
                
                Button("🤚🏻 Braille") {
                    filterAnnotations(by: "Braille Menus") // Filter by tag
                }
                .filterButtonStyle()
                
                Button("🚗 Parking") {
                    filterAnnotations(by: "Parking") // Filter by tag
                }
                .filterButtonStyle()
                
                Button("🚪 Wide Doors") {
                    filterAnnotations(by: "Wide Doors") // Filter by tag
                }
                .filterButtonStyle()
                
            }
        }
    }
    
    private func filterAnnotations(by tag: String) {
        if tag.isEmpty {
            filteredAnnotations = [] // Clear filtered annotations if no tag is selected
        } else {
            filteredAnnotations = annotations.filter { $0.tags.contains(tag) } // Filter based on selected tag
        }
    }
}

/**
 This function gets annotations from a database.
 */
func getAnnotations() -> [CustomAnnotation] {
    // Hardcoded for testing
    let annotation1 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.161598, longitude: -86.776619),
                                       title: "Miranda's", subtitle: "🍸 Bar", tags: ["Elevator", "Ramps"])
    let annotation2 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.138240, longitude: -86.800450),
                                       title: "Taco Mama", subtitle: "🍽️ Restaurant", tags: ["Elevator", "Braille Menus"])
    let annotation3 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1551, longitude: -86.8101),
                                       title: "The Catbird Seat", subtitle: "🍽 Restaurant", tags: ["Ramp", "Braille Menus"])
    let annotation4 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1577, longitude: -86.8021),
                                       title: "Hattie B's Hot Chicken", subtitle: "🍽 Restaurant", tags: ["Ramp", "Parking"])
    let annotation5 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1539, longitude: -86.7866),
                                       title: "The Pancake Pantry", subtitle: "🍽 Restaurant", tags: ["Ramp", "Parking"])
    let annotation6 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1550, longitude: -86.7984),
                                       title: "Prince's Hot Chicken", subtitle: "🍽 Restaurant", tags: ["Ramp", "Parking"])
    let annotation7 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1558, longitude: -86.7834),
                                       title: "Tootsies Orchid Lounge", subtitle: "🍸 Bar", tags: ["Ramp", "Braille"])
    let annotation8 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1395, longitude: -86.8412),
                                       title: "The Bluebird Cafe", subtitle: "🍽 Restaurant", tags: ["Ramp", "Wide Doors"])
    let annotation9 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1591, longitude: -86.7789),
                                       title: "Acme Feed & Seed", subtitle: "🍸 Bar", tags: ["Rooftop"])
    let annotation10 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1583, longitude: -86.4351),
                                       title: "5 Spot", subtitle: "🍸 Bar", tags: ["Live Music"])
    let annotation11 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1553, longitude: -86.7901),
                                       title: "Losers Bar & Grill", subtitle: "🍸 Bar", tags: ["Casual"])
    let annotation12 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1602, longitude: -86.7848),
                                        title: "Puckett's Grocery & Restaurant", subtitle: "🍽 Restaurant", tags: ["Comfort Food"])
    let annotation13 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1674, longitude: -86.7913),
                                        title: "Germantown Cafe", subtitle: "🍽 Restaurant", tags: ["Brunch"])
    let annotation14 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1635, longitude: -86.7794),
                                        title: "The Stillery", subtitle: "🍸 Bar", tags: ["Craft Cocktails"])
    let annotation15 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1378, longitude: -86.7980),
                                        title: "The Mockingbird", subtitle: "🍽 Restaurant", tags: ["Modern American"])
    let annotation16 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1835, longitude: -86.7710),
                                        title: "The Pharmacy Burger Parlor", subtitle: "🍽 Restaurant", tags: ["Burgers"])
    let annotation17 = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.1435, longitude: -86.7907),
                                        title: "Tin Roof", subtitle: "🍸 Bar", tags: ["Live Music"])

    
    return [annotation1, annotation2, annotation3, annotation4, annotation5,
            annotation6, annotation7, annotation8, annotation9, annotation10,
            annotation11, annotation12, annotation13, annotation14, annotation15,
            annotation16, annotation17]
}

/**
 This structure representd the view of the map.
 */
struct Map: UIViewRepresentable {
    var annotations: [CustomAnnotation] // Receive annotations from HomeMap
    var selectedAnnotation: CustomAnnotation?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // Set the initial map region
        let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.1627, longitude: -86.7816), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.region = mapRegion
        
        // Add annotations to the map
        mapView.addAnnotations(annotations)

        return mapView // Return the representable view
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove existing annotations
        uiView.removeAnnotations(uiView.annotations)
        // Add the new annotations
        uiView.addAnnotations(annotations)
    }
}

// Button style extension
extension View {
    func filterButtonStyle() -> some View {
        self.padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(20)
            .frame(minWidth: 30)
            .padding()
    }
    
    func uploadButtonStyle() -> some View {
        self.padding()
            .foregroundColor(Color.black)
            .frame(width: 50, height: 50)
            .padding()
            .font(.system(size: 40)) // Increase font size for a bigger button text
        
    }
}

// Preview
#Preview {
    HomeMap()
}


