//
//  TabMainView.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 05/01/2023.
//

import SwiftUI

struct TabMainView: View {
    @EnvironmentObject var cameraModel: CameraModel
    
    var body: some View {
        TabView {
            SpheroView()
                .tabItem {
                    Label("Sphero", systemImage: "circle.circle")
                }
            ScannerView()
                .tabItem {
                    Label("Scanner", systemImage: "camera.circle")
                }
                .ignoresSafeArea()
                .environmentObject(cameraModel)
        }
    }
}

struct TabMainView_Previews: PreviewProvider {
    static var previews: some View {
        TabMainView()
    }
}
