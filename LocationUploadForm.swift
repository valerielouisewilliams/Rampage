//
//  LocationUploadForm.swift
//  Rampage
//
//  Created by Valerie Williams on 9/29/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct LocationUploadForm: View {
    @State private var nameText: String = ""
    @State private var addressText: String = ""
    @State private var features: String = ""
    @State private var featureItem: PhotosPickerItem?
    @State private var featureImage: Image?
    
    var body: some View {
        VStack {
            TextField("Name", text: $nameText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding()
            TextField("Address", text: $addressText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding()
            TextField("Feature", text: $features)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding()
            PhotosPicker("Select a photo of the accessibility feature", selection: $featureItem, matching: .images)
                .padding()
                .background(Color.black) // Customize background
                .cornerRadius(20) // Rounded corners
                .foregroundColor(.white) // Text color
                .font(.headline) // Font style
            featureImage?
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
    
            Button("Submit") {
                // connect to backend
            }
            .onChange(of: featureItem) {
                Task {
                    if let loaded = try? await featureItem?.loadTransferable(type: Image.self) {
                        featureImage = loaded
                    } else {
                        print("FAILED")
                    }
                }
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(20)
            .frame(minWidth: 30)
            .padding()
            .font(.headline) // Font style

        }
    }
}


