//
//  ScannerView.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 10/01/2023.
//

import SwiftUI

struct ScannerView: View {
    @EnvironmentObject var cameraModel: CameraModel
    @StateObject var coreMlInterface = CoreMLInterface()
    @State var prediction: ImagePredictor.Prediction? = nil
    @State var cameraViewReady: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        CameraView(prediction: $prediction)
        .onAppear {
            cameraViewReady = true
            print("camera view ready")
        }
        .onAppear{
        }.onReceive(timer) { time in
            if cameraViewReady {
                cameraModel.capturePhoto()
                if let photo = cameraModel.photo, let image = photo.image {
                    coreMlInterface.predictionFor(image: image)
                }
            }
        }.onChange(of: coreMlInterface.prediction) { newPrediction in
            prediction = newPrediction
        }.onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var cameraModel = CameraModel()
    static var previews: some View {
        ScannerView().environmentObject(cameraModel)
    }
}
