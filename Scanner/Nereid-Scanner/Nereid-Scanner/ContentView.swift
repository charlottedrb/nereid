//
//  ContentView.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 16/12/2022.
//

import SwiftUI

struct CustomColor {
    static let marine = Color("marine")
    static let sky = Color("sky")
    static let berry = Color("berry")
}

struct ContentView: View {
    @State var isStarted = false
    @EnvironmentObject var cameraModel: CameraModel
    
    var body: some View {
//        NavigationView {
            VStack {
//                NavigationLink(destination: TabMainView().environmentObject(cameraModel), isActive: $isStarted) {}
//                NavigationLink(destination: ScannerView(), isActive: $isStarted) {}
                ScannerView()
//            }
//            .navigationTitle("Scanner")
//            .navigationBarTitleDisplayMode(.inline)
//            .padding()
        }.onAppear {
            SharedToyBox.instance.searchForBoltsNamed(["SB-A729"]) { err in
                if err == nil {
                    isStarted = true
                } else {
                    print(err ?? "err")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
