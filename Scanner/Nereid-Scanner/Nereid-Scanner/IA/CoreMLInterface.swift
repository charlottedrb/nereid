//
//  CoreMLInterface.swift
//  SwiftUI_CoreML
//
//  Created by Charlotte Der Baghdassarian on 28/10/2022.
//

import Foundation
import UIKit

class CoreMLInterface: ObservableObject {
    @Published var prediction: ImagePredictor.Prediction = ImagePredictor.Prediction(classification: "", confidencePercentage: "")
    
    /// A predictor instance that uses Vision and Core ML to generate prediction strings from a photo.
    let imagePredictor = ImagePredictor()
    /// The largest number of predictions the main view controller displays the user.
    var predictionsToShow = 1
    
    func predictionFor(image: UIImage) {
        classifyImage(image)
    }
}

extension CoreMLInterface {
    // MARK: Image prediction methods
    /// Sends a photo to the Image Predictor to get a prediction of its content.
    /// - Parameter image: A photo.
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            print("No predictions. (Check console log.)")
//            predictionText = "No predictions. (Check console log.)"
            return
        }

        let formattedPredictions = formatPredictions(predictions)
        prediction = formattedPredictions.first!
        // prediction =
//        prediction = formattedPredictions.joined(separator: "\n")
    }

    /// Converts a prediction's observations into human-readable strings.
    /// - Parameter observations: The classification observations from a Vision request.
    /// - Tag: formatPredictions
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [ImagePredictor.Prediction] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [ImagePredictor.Prediction] = predictions.prefix(predictionsToShow).map { prediction in
//            var name = prediction.classification
//
//            // For classifications with more than one name, keep the one before the first comma.
//            if let firstComma = name.firstIndex(of: ",") {
//                name = String(name.prefix(upTo: firstComma))
//            }
//
//            return "\(name) - \(prediction.confidencePercentage)%"
            return prediction
        }
        
        return topPredictions
    }
}

