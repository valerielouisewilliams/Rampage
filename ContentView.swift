//
//  ContentView.swift
//  Rampage
//
//  Created by Valerie Williams on 9/28/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {

        if (UserDataManager.shared.loadOnboardStatus() == false) {
            LandingView()
        } else {
            HomeMap()
        }
        
    }
}

#Preview {
    ContentView()
}
