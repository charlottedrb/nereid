//
//  SpheroLoading.swift
//  Nereid-Scanner
//
//  Created by Charlotte Der Baghdassarian on 16/12/2022.
//

import Foundation
import UIKit

class SpheroLoading {
    static let instance = SpheroLoading()
    
    private let nbOfTears = 64
    
    func loadIn() {
        guard let bolt = SharedToyBox.instance.bolt else {
            print("Sphero not connected")
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            var x = 0
            var y = 0
            for i in 0...64 {
                if i != 0 && i % 8 == 0 {
                    x += 1
                    y = 0
                }
                bolt.drawMatrix(pixel: Pixel(x: x, y: y), color: UIColor(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: 1.0
                ))
                if i == 64 {
                    timer.invalidate()
                }
                y += 1
            }
        }
    }
    
    func loadOut() {
        guard let bolt = SharedToyBox.instance.bolt else {
            print("Sphero not connected")
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            var x = 7
            var y = 7
            for i in 0...64 {
                if i != 0 && i % 8 == 0 {
                    x -= 1
                    y = 7
                }
                bolt.drawMatrix(pixel: Pixel(x: x, y: y), color: .clear)
                if i == 64 {
                    timer.invalidate()
                }
                y -= 1
            }
        }
    }
}
