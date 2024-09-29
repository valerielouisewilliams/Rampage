//  LandingView.swift
//  Rampage
//
//  Created by Valerie Williams on 9/28/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct LandingView: View {
    @State private var step: Int = 1
    @State private var onboardingComplete: Bool = false
    var locationManager: CLLocationManager?
    
    var body: some View {
        VStack {

            Group {
                switch step {
                case 1: // Welcome message
                    welcomeMessage
                    
                case 2: // Location services message
                    locationServicesMessage
                    
                case 3: // Ready to view the map message
                    readyToViewMapMessage
                
                case 4:
                    HomeMap()
                    
                default:
                    Text("This should not appear...")
                }
            }
        }
    }
    
    private var welcomeMessage: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 300, height: 250, alignment: .center)
            
            Button("Get Started") {
                step += 1
            }
            .buttonStyle()
        }
    }
    
    private var locationServicesMessage: some View {
        VStack {
            Image(systemName: "location.circle")
                .font(.system(size: 50))
            
            Text("Turn location services on so we know what's around!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Button("Location Permission") {
 
            }
            .buttonStyle()
            
            Button("Continue") {
                step += 1
            }
            .buttonStyle()
        }
    }
    
    private var readyToViewMapMessage: some View {
        VStack {
            Image(systemName: "map")
                .font(.system(size: 50))
            
            Text("You're ready to view the map!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Button("Finish") {
                UserDataManager.shared.saveOnboardedStatus(true)
                step += 1
            }
            .buttonStyle()
        }
    }
    
}

extension View {
    func buttonStyle() -> some View {
        self.padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding()
    }
}

 #Preview {
     LandingView()
 }

