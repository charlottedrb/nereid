//
//  GameManager.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 31/12/2022.
//

import Foundation
import SwiftUI

struct StepModel:Identifiable {
    var id = UUID().uuidString
    var index: Int
    var name: String
    var desc: String = ""
    var state: Bool = false
    var data: String = "launch"
    var triggerable: Bool = false
}

struct LavaJsonData: Decodable {
    var id: String
    var placed: Bool
    var state: Bool
}

class GameManager: ObservableObject {
    @Published var currentStep = 1
    @Published var taskComplete = false
    @ObservedObject var bleObservable = BLEObservable()
    let utils = Utils()
    var lavaCallback:(()->())?
    var twCallback:(()->())?
    
    private var lavaStateArray:[String: Bool] = [
        "0x93cc3cac" : false,
        "0x338a14ac" : false,
        "0x533b73ad" : false,
    ]
    
    @Published var steps = [
        StepModel(index: 1, name: "Étape 1", desc: "Set coral", data: "reset", triggerable: true),
        
        StepModel(index: 2, name: "Étape 2", desc: "TW 1", triggerable: true),
//        StepModel(index: 3, name: "Étape 3", desc: "Listen TW"),
        StepModel(index: 3, name: "Étape 3", desc: "Sound : 1", triggerable: true),
        
        StepModel(index: 4, name: "Étape 4", desc: "Launch coral", data: "start", triggerable: true),
        StepModel(index: 5, name: "Étape 5", desc: "Listen coral"),
        StepModel(index: 6, name: "Étape 6", desc: "TW 2", triggerable: true),
        //StepModel(index: 8, name: "Étape 8", desc: "Listen TW"),
        StepModel(index: 7, name: "Étape 7", desc: "Sound : 2", triggerable: true),
        
        StepModel(index: 8, name: "Étape 8", desc: "Launch pipe", triggerable: true),
        StepModel(index: 9, name: "Étape 9", desc: "Listen pipe"),
        StepModel(index: 10, name: "Étape 10", desc: "Sound : woosh", triggerable: true),
        
        StepModel(index: 11, name: "Étape 11", desc: "Launch lava", triggerable: true),
        StepModel(index: 12, name: "Étape 12", desc: "Process lava", triggerable: true),
    
        StepModel(index: 13, name: "Étape 13", desc: "TW 3", triggerable: true),
//        StepModel(index: 16, name: "Étape 16", desc: "Listen TW"),
        StepModel(index: 14, name: "Étape 14", desc: "Sound : 3", triggerable: true),
    ]
    
    private var TW_UUID = "235FBD52-8E20-8E89-E0C2-40DDFB5E62E4"
    private var TW2_UUID = "810538B9-2A0D-E008-420D-8A18C5988A50"
    private var CORAL_UUID = "856724E2-10D5-57EE-B398-0CAF130C6D02"
    private var PIPE_UUID = "AC8159F7-F931-7EB2-0C7E-A4168767C43A"
    private var LAVA_UUID = "D0785064-5AAE-0477-64B8-FF24A5E0CB49"
    
    
    func start(step: Int) {
        self.currentStep = step
        self.updateOnRestart()
        self.onStepChanged()
    }
    
    private func onStepChanged() {
        
        self.updateFront()
        
        switch currentStep {
            
            //************************************//
            // PREPARATION : LED CORAIL, RFID     //
            //************************************//
            
        case 1:
            bleObservable.sendData(data: steps[0].data.data(using: .utf8)!, target: self.CORAL_UUID) { response in
                print(self.steps[0].data.data(using: .utf8)!)
                if (response == true) {
                    print("coral ready")
                    self.taskComplete = true
                    self.currentStep += 1
                    self.onStepChanged()
                } else {
                    print("Task 1 : Error when sending data")
                }
            }
            
            //************************************//
            // PREPARATION : FIN                  //
            //************************************//
            
            //************************************//
            // 1 : ARRIVÉE, APPEL SCIENTIFIQUES 1 //
            //************************************//
            
        case 2:
            self.twProcess {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
//            self.utils.playSoundInLoop(interval: 2.0)
//            BLEManager.instance.listenForTwMessages { data in
//                print(data as Any)
//                if data != nil{
//                    self.utils.stopSoundInLoop()
//                }
//            }

//            bleObservable.sendData(data: steps[1].data.data(using: .utf8)!, target: self.TW2_UUID) { response in
//                if (response == true) {
//                    self.taskComplete = true
//                    self.currentStep += 1
//                    self.onStepChanged()
//                } else {
//                    print("Task 1 : Error when sending data")
//                }
//            }
        case 3:
            self.utils.playSound(resourceTitle: "appel_1") {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
//            BLEManager.instance.listenForTwMessages { data in
//                print("message")
//                if data != nil{
//                    self.taskComplete = true
//                    self.currentStep += 1
//                    self.onStepChanged()
//                }
//            }
            
            //************************************//
            // 1 : FIN ETAPE 1                    //
            //************************************//
            
            //************************************//
            // 2 : RFID SUITE                     //
            //************************************//
            
        case 4:
            bleObservable.sendData(data: steps[3].data.data(using: .utf8)!, target: self.CORAL_UUID) { response in
                print(response)
                if (response == true) {
                    self.taskComplete = true
                    self.currentStep += 1
                    self.onStepChanged()
                } else {
                    print("Task 5 : Error when sending data")
                }
            }
            
        case 5:
            self.coralProcess {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
            
        case 6:
            self.twProcess {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
//            bleObservable.sendData(data: steps[6].data.data(using: .utf8)!, target: self.TW_UUID) { response in
//                if (response == true) {
//                    self.taskComplete = true
//                    self.currentStep += 1
//                    self.onStepChanged()
//                } else {
//                    print("Error when sending data")
//                }
//            }
        case 7:
            self.utils.playSound(resourceTitle: "appel_2") {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
//            BLEManager.instance.listenForTwMessages { data in
//                if data != nil{
//                    self.taskComplete = true
//                    self.currentStep += 1
//                    self.onStepChanged()
//                }
//            }
//        case 9:
//            self.utils.playSound(resourceTitle: "2") {
//                self.taskComplete = true
//                self.currentStep += 1
//                self.onStepChanged()
//            }
            
            //************************************//
            // 2 : RFID FIN                       //
            //************************************//
            
            
            //************************************//
            // 3 : POISSONS                       //
            //************************************//
            
            // Étape sur tablette, pas d'intéraction serveur
            
            //************************************//
            // 3 : POISSONS FIN                   //
            //************************************//
            
            //************************************//
            // 4 : TUYAUX                         //
            //************************************//
            
        case 8:
            bleObservable.sendData(data: steps[9].data.data(using: .utf8)!, target: self.PIPE_UUID) { response in
                if (response == true) {
                    self.taskComplete = true
                    self.currentStep += 1
                    self.onStepChanged()
                } else {
                    print("Task 5 : Error when sending data")
                }
            }
            
            //Ecoute du bouton
        case 9:
            BLEManager.instance.listenForPipeMessages { data in
                if data != nil{
                    self.taskComplete = true
                    self.currentStep += 1
                    self.onStepChanged()
                }
            }
            
            //ASPIRATION
        case 10:
            self.utils.playSound(resourceTitle: "woosh") {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
            
            //************************************//
            // 4 : TUYAUX FIN                     //
            //************************************//
            
            //************************************//
            // 5 : COULÉE DE LAVE                 //
            //************************************//
            
        case 11:
            bleObservable.sendData(data: steps[12].data.data(using: .utf8)!, target: self.LAVA_UUID) { response in
                if (response == true) {
                    self.taskComplete = true
                    self.currentStep += 1
                    self.onStepChanged()
                } else {
                    print("Task 5 : Error when sending data")
                }
            }


        case 12:
            self.lavaProcess {
                print("Lava done")

                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
            
            
            
            //************************************//
            // 5 : COULÉE DE LAVE                 //
            //************************************//
            
            //************************************//
            // 6 : EXPLICATION SCIENTIFIQUE       //
            //************************************//
            
        case 13:
            self.twProcess {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
            
        case 14:
            self.utils.playSound(resourceTitle: "appel_3") {
                self.taskComplete = true
                self.currentStep += 1
                self.onStepChanged()
            }
            
            //************************************//
            // 6 : EXPLICATION SCIENTIFIQUE FIN   //
            //************************************//
            
        case 20:
            print("Terminé")
        default:
            if currentStep > 20 {
                break
            }
            self.taskComplete = true
            self.currentStep += 1
            self.onStepChanged()
        }
    }
    
    
    private func startTask(task: @escaping () -> Bool, completion: @escaping (Bool) -> Void) {
        completion(task())
    }
    
    private func lavaProcess(completion: @escaping () -> Void) {
        var lavaSounds: [String] = ["Bard5A", "Bard5B", "Bard5C", "Bard5D", "Bard5E"]
        
        BLEManager.instance.listenForLavaMessages { data in
            if data != nil{
                let str = String(data: data!, encoding: .utf8)
                if(str == "false") {
                    self.utils.playSound(resourceTitle: "BardFalse5A") {
                        
                    }
                } else {
                    self.utils.playSound(resourceTitle: self.utils.getNextSound(sounds: &lavaSounds)) {
                        completion()
                        self.lavaStateArray[str!] = true
                    }
                }
            }
            
            print(self.lavaStateArray)
        }
    }
    
    private func twProcess(completion: @escaping () -> Void) {
        let string = "hello"
        bleObservable.sendData(data: string.data(using: .utf8)!, target: self.TW2_UUID) { response in
            if (response == true) {
                self.utils.playSoundInLoop(interval: 1.0)
                BLEManager.instance.listenForTwMessages { data in
                    print(data as Any)
                    if data != nil{
                        self.utils.stopSoundInLoop()
                        completion()
                    }
                }
            } else {
                print("TW : Error when sending data")
            }
        }
    }
    
    private func coralProcess(completion: @escaping () -> Void) {
        var bubbleSounds: [String] = ["bubble", "bubble-2"]
        print("coralProcess")
        BLEManager.instance.listenForRfidMessages { data in
            if data != nil{
                print("coucou")
                let str = String(data: data!, encoding: .utf8)
                if str == "sound" {
                    print("receive message")
                    self.utils.playSound(resourceTitle: self.utils.getNextSound(sounds: &bubbleSounds)) {
                        completion()
                    }
                } else {
                    self.taskComplete = true
                    self.currentStep += 1
                    self.onStepChanged()
                }
            }
        }
    }
    
    
    private func updateFront() {
        for step in steps {
            if step.index == self.currentStep {
                self.steps[step.index-1].state = true
            }
        }
    }
    
    private func updateOnRestart() {
        for step in steps {
            if step.index > self.currentStep {
                self.steps[step.index-1].state = false
            } else {
                self.steps[step.index-1].state = true
            }
        }
    }
}


