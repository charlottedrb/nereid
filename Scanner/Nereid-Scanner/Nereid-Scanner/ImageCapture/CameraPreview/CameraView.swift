//
//  CameraView.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 10/01/2023.
//

import SwiftUI
import AVFoundation
import Combine

final class CameraModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var willCapturePhoto = false
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
}

struct CameraView: View {
    @State var currentZoomFactor: CGFloat = 1.0
    @State var showExplanations: Bool = false
    @State var showLoader: Bool = false
    @EnvironmentObject var cameraModel: CameraModel
    @Binding var prediction: ImagePredictor.Prediction?
    
    var capturedPhotoThumbnail: some View {
        Group {
            if cameraModel.photo != nil {
                Image(uiImage: cameraModel.photo.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .animation(.spring())
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                CameraPreview(session: cameraModel.session)
                .alert(isPresented: $cameraModel.showAlertError, content: {
                    Alert(title: Text(cameraModel.alertError.title), message: Text(cameraModel.alertError.message), dismissButton: .default(Text(cameraModel.alertError.primaryButtonTitle), action: {
                        cameraModel.alertError.primaryAction?()
                    }))
                })
                .overlay(loadingOverlay)
                .animation(.easeInOut)
                .scaledToFill()
            }.onAppear {
                cameraModel.configure()
            }
            ZStack {
                if !showLoader {
                    Text("Cherche les poissons contaminés !").padding(.all).foregroundColor(.white)
                }
            }
            .background(.black)
            .cornerRadius(15.0)
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: prediction, perform: { newValue in
            if newValue!.classification != "Trash" {
                showLoader = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showExplanations = true
                    showLoader = false
                }
            }
        })
        .sheet(isPresented: $showExplanations) {
            if let currentPrediction = $prediction, let bindedPrediction = Binding(currentPrediction) {
                ExplanationsView(prediction: bindedPrediction)
            }
        }
    }
    
    @ViewBuilder private var loadingOverlay: some View {
        if showLoader {
            Group {
                ProgressView {
                    Text("Reconnaissance du poisson").foregroundColor(.white)
                }
            }.padding(.all).background(.blue).cornerRadius(15.0)
        }
    }
}
