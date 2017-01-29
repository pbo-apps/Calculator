//
//  ViewController.swift
//  Calculator
//
//  Created by Pete Bounford on 27/01/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet private weak var commandHistory: UILabel!
    
    private var userIsInMiddleOfTyping = false

    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInMiddleOfTyping {
            display.text!.append(digit)
        } else {
            display.text = digit
            userIsInMiddleOfTyping = digit != "0"
        }
        if !brain.isPartialResult {
            brain.description = nil
        }
    }
    
    @IBAction private func touchDecimalPoint(_ sender: UIButton) {
        if userIsInMiddleOfTyping {
            if !display.text!.contains(".") {
                display.text!.append(".")
            }
        } else {
            display.text = "0."
            userIsInMiddleOfTyping = true
        }
    }
    
    private var displayValue: Double {
        get {
            // Double initialiser returns an optional Double - if the string value cannot be converted it will return nil (not set)
            // By unwrapping it directly we are assuming the display will only ever contain a double
            return Double(display.text!)!
        }
        set {
            display.text = newValue.cleanValue
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        userIsInMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {
            brain.setOperand(operand: displayValue)
            brain.performOperation(symbol: mathematicalSymbol)
            displayValue = brain.result
            updateCommandHistory()
        }
    }
    
    private var memoryValue: Double?
    
    @IBAction private func setMemoryValue() {
        memoryValue = displayValue
    }
    
    @IBAction private func getMemoryValue() {
        if let value = memoryValue {
            displayValue = value
        }
    }
    
    private func updateCommandHistory() {
        if let currentDescription = brain.description {
            commandHistory.text = currentDescription
            if brain.isPartialResult {
                commandHistory.text?.append(" ...")
            } else {
                commandHistory.text?.append(" =")
            }
        } else {
            commandHistory.text = " "
        }
    }
    
}

