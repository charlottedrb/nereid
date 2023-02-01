//
//  SpheroView.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 05/01/2023.
//

import SwiftUI

struct SpheroView: View {
    var body: some View {
        VStack {
            Button("Connect Sphero") {
                SharedToyBox.instance.searchForBoltsNamed(["SB-A729"]) { err in
                    if err == nil {
                        print("Connected")
                    }
                }
            }
            Button("Load tears") {
                SpheroLoading.instance.loadIn()
            }
            Button("Empty loading") {
                SpheroLoading.instance.loadOut()
            }
        }.padding()
    }
}

struct SpheroView_Previews: PreviewProvider {
    static var previews: some View {
        SpheroView()
    }
}
