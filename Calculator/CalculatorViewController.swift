//
//  ViewController.swift
//  Calculator
//
//  Created by Pete Bounford on 27/01/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    private struct Storyboard {
        static let DrawGraphSegue = "Draw Graph"
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.DrawGraphSegue {
            if let graphView = segue.destination.contentViewController as? GraphViewController {
                graphView.pointsPerUnit = 10.0
                graphView.function = brain.program
                graphView.trigSetting = brain.trigSetting
                graphView.title = brain.description == nil ? "No graph to display" : "y = " + brain.description!
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case Storyboard.DrawGraphSegue:
            return !brain.isPartialResult
        default:
            return true
        }
    }
    
    // MARK: - View
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self {
            if let gvc = secondaryViewController.contentViewController as? GraphViewController, gvc.function == nil {
                return true
            }
        }
        return false
    }
    
    // MARK: - Model
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if let mathematicalSymbol = sender.currentTitle {
            if userIsInMiddleOfTyping {
                brain.setOperand(operand: displayValue)
            }
            userIsInMiddleOfTyping = false
            brain.performOperation(symbol: mathematicalSymbol)
            displayValue = brain.result
        }
    }
    
    private func setVariable(_ sender: UIButton) {
        if let variable = sender.currentTitle {
            brain.variableValues[variable] = displayValue
            displayValue = brain.result
            userIsInMiddleOfTyping = false
        }
    }
    
    @IBAction private func touchVariable(_ sender: UIButton) {
        if userIsInputtingVariable {
            setVariable(sender)
            userIsInputtingVariable = false
        } else {
            useVariable(sender)
        }
    }
    
    private func useVariable(_ sender: UIButton) {
        brain.setOperand(variableName: sender.currentTitle!)
        displayValue = brain.result
        userIsInMiddleOfTyping = false
    }
    
    private var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction private func save() {
        savedProgram = brain.program
    }
    
    @IBAction private func restore() {
        if savedProgram != nil {
            userIsInMiddleOfTyping = false
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBOutlet weak var inputVariable: UIButton!
    
    private var inputVariableButtonBackgroundColor: UIColor?
    private var userIsInputtingVariable: Bool = false {
        willSet {
            if inputVariableButtonBackgroundColor == nil {
                inputVariableButtonBackgroundColor = inputVariable.backgroundColor
            }
            inputVariable.backgroundColor = newValue ? UIColor.orange : inputVariableButtonBackgroundColor!
        }
    }
    
    @IBAction private func toggleVariableInput(_ sender: UIButton) {
        if let symbol = sender.currentTitle {
            if symbol == "→" {
                userIsInputtingVariable = !userIsInputtingVariable
            } else if userIsInputtingVariable {
                userIsInputtingVariable = false
            }
        }
    }
    
    @IBAction func toggleRadiansAndDegrees(_ sender: UIButton) {
        sender.setTitle(brain.trigSetting.rawValue, for: UIControlState.normal)
        brain.trigSetting = brain.trigSetting.change()
        displayValue = brain.result
    }
    
    @IBAction func undo() {
        if userIsInMiddleOfTyping {
            if display.text!.characters.count > 1 {
                display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            } else {
                display.text = "0"
            }
        } else {
            brain.undoLastOperation()
            displayValue = brain.result
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
