//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Pete Bounford on 28/01/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // Type Double inferred from 0.0 (or indeed anyInt.anyInt)
    private var accumulator = 0.0;
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    var operations: Dictionary<String, Double> = [
        "π" : M_PI,
        "e" : M_E
    ]
    
    func performOperation(symbol: String) {
        if let constant = operations[symbol] {
            accumulator = constant
        } else {
            switch symbol {
            case "√":
                accumulator = sqrt(accumulator)
            default:
                break
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
