//
//  Nereid_ScannerApp.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 16/12/2022.
//

import SwiftUI

@main
struct Nereid_ScannerApp: App {
    @StateObject var cameraModel = CameraModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(cameraModel)
        }
    }
}
