//
//  ExplanationsView.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 11/01/2023.
//

import SwiftUI

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fish = try? JSONDecoder().decode(Fish.self, from: jsonData)

import Foundation

// MARK: - FishElement
struct User: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case name
        case designation
        case email
    }
    
    var id = UUID()
    var name: String
    var designation: String
    var email: String
}

struct Fish: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case mlmodel
        case title
        case description
        case location
        case food
        case size
        case rate
    }
    
    var id = UUID()
    var mlmodel, title, description, location,  food, size: String
    var rate: Int
}

class ReadData: ObservableObject  {
    @Published var fishes = [Fish]()
        
    init(){
        loadData()
    }
    
    func loadData()  {
        guard let url = Bundle.main.url(forResource: "fishdata", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        
        if let data = try? Data(contentsOf: url), let fishes =  try? JSONDecoder().decode([Fish].self, from: data){
            self.fishes = fishes
        }
    }
}

struct ExplanationsView: View {
    @State var fish: Fish = Fish(mlmodel: "Fish", title: "Poisson papillon masqué", description: "Le poisson papillon possède une couleur jaune très reconnaissable.", location: "Mer arabique", food: "Carnivore", size: "15 cm", rate: 100)
    @State var total = 0
    @State var changeColor: Bool = false
    @StateObject var data = ReadData()
    @Binding var prediction: ImagePredictor.Prediction

    var titleSize: CGFloat = 70.0
    var bodySize: CGFloat = 30.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 80.0) {
            HStack {
                Spacer()
                Text(fish.title)
                    .fontWeight(.bold)
                    .foregroundColor(CustomColor.marine)
                    .font(.custom("TheForegenRoughOne", size: titleSize, relativeTo: .largeTitle))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            
            VStack {
                HStack(spacing: 10.0) {
                    Spacer()
                    CardView(title: "Lieu de vie", content: fish.location)
                    CardView(title: "Lieu de vie", content: fish.location)
                    Spacer()
                }.frame(height: 120.0)
                HStack(spacing: 10.0) {
                    Spacer()
                    CardView(title: "Régime alimentaire", content: fish.food)
                    CardView(title: "Taille moyenne", content: fish.size)
                    Spacer()
                }.frame(height: 120.0)
                
            }
            
            VStack {
                Spacer()
                Text("\(total)%").fontWeight(.bold)
                    .foregroundColor(changeColor ? CustomColor.berry : CustomColor.marine)
                    .font(.custom("TheForegenRoughOne", size: titleSize, relativeTo: .largeTitle))
                    .onChange(of: total) { newValue in
                        if newValue == fish.rate {
                            changeColor = true
                        }
                    }
                Text("de larmes de sirène détectées").fontWeight(.bold)
                    .foregroundColor(CustomColor.marine)
                    .font(.custom("TheForegenRoughOne", size: titleSize, relativeTo: .largeTitle))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }.onAppear {
                self.addNumberWithRollingAnimation()
            }
            
            .onChange(of: fish.rate) { newValue in
                self.addNumberWithRollingAnimation()
            }
            
            HStack {
                Spacer()
                Button("Récupérer les larmes de la sirène") {
                    SpheroLoading.instance.loadIn()
                }.foregroundColor(CustomColor.sky)
                    .font(.custom("TheForegenRoughOne", size: bodySize, relativeTo: .callout))
                    .padding(.all, 20.0)
                    .background(CustomColor.marine)
                    .cornerRadius(15.0)
                    
                
                Spacer()
            }
            Spacer()
        }
        .onAppear {
            if ReadData().fishes != nil {
                if let currentFish = ReadData().fishes.first(where: {$0.mlmodel == prediction.classification}) {
                   fish = currentFish
                }
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .topLeading
            )
        .padding(.all)
        .background(CustomColor.sky.edgesIgnoringSafeArea(.all))
        
    }
    
    /// Creates a rolling animation while adding entered number
    func addNumberWithRollingAnimation() {
        withAnimation {
            // Decide on the number of animation steps
            let animationDuration = 1500 // milliseconds
            let steps = min(abs(fish.rate), 100)
            let stepDuration = (animationDuration / steps)
            
            // add the remainder of our entered num from the steps
            total += fish.rate % steps
            // For each step
            (0..<steps).forEach { step in
                // create the period of time when we want to update the number
                // I chose to run the animation over a second
                let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                let deadline = DispatchTime.now() + updateTimeInterval
                
                // tell dispatch queue to run task after the deadline
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    // Add piece of the entire entered number to our total
                    self.total += Int(fish.rate / steps)
                }
            }
        }
    }
}

struct ExplanationsView_Previews: PreviewProvider {
    @State static var prediction: ImagePredictor.Prediction = ImagePredictor.Prediction(classification: "Strawberry", confidencePercentage: "100")
    static var previews: some View {
        ExplanationsView(prediction: $prediction)
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
            .previewDevice("iPad Pro (11-inch) (4th generation)")
            
            
    }
}

struct CardView: View {
    var title: String
    var content: String
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                ZStack {
                    Text(title).foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding(.all, 10.0)
                        .frame(maxWidth: .infinity)
                        .background(CustomColor.berry)
                        .font(.custom("TheForegenRoughOne", size: 30.0, relativeTo: .body))
                        
                }.frame(maxWidth: .infinity)
                ZStack {
                    Text(content)
                        .foregroundColor(CustomColor.berry)
                        .padding(.all, 10.0)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .font(.custom("TheForegenRoughOne", size: 30.0, relativeTo: .body))
                }
            }
            .cornerRadius(15.0)
            .overlay(
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(CustomColor.berry, lineWidth: 2.0)
            )
            
        }
    }
}
