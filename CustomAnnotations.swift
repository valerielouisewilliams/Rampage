//
//  CustomAnnotations.swift
//  vandyhacks_project
//
//  Created by Valerie Williams on 9/28/24.
//

import Foundation
import SwiftUI
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var tags: [String] //holds our tagged attributes, i.e. accessability features
    
    /**
     This function initializes a CustomAnnotation object.
     */
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, tags: [String]) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.tags = tags
    }
    
    
}
