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
            if !userIsInMiddleOfTyping {
                commandHistoryValue = brain.description ?? " "
            }
        }
    }
    
    private var commandHistorySuffix: String {
        get {
            return brain.isPartialResult ? " ..." : " ="
        }
    }
    
    private var commandHistoryValue: String {
        get {
            return commandHistory.text!
        }
        set {
            commandHistory.text = newValue == " " ? newValue : newValue + commandHistorySuffix
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        userIsInMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {
            if !brain.isPartialResult {
                brain.clear()
            }
            brain.setOperand(operand: displayValue)
            brain.performOperation(symbol: mathematicalSymbol)
            displayValue = brain.result
        }
    }
    
    private let variable: String = "MR"
    
    @IBAction private func setMemoryValue() {
        brain.variableValues[variable] = displayValue
        userIsInMiddleOfTyping = false
    }
    
    @IBAction private func getMemoryValue() {
        if let value = brain.variableValues[variable] {
            displayValue = value
            userIsInMiddleOfTyping = true
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            userIsInMiddleOfTyping = false
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
}

