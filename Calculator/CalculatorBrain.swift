//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Pete Bounford on 28/01/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import Foundation

extension Double {
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1.0) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

class CalculatorBrain {
    
    // Type Double inferred from 0.0 (or indeed anyInt.anyInt)
    private var accumulator = 0.0;
    
    private var internalProgram = [AnyObject]()
    
    private var currentVariable: String?
    private var currentOperand: String {
        get {
            let operand = currentVariable ?? accumulator.cleanValue
            currentVariable = nil
            return operand
        }
    }
    
    func setOperand(operand: Double) {
        // If we have a current variable then no need to setOperand as it's already been set
        if currentVariable == nil {
            if !isPartialResult {
                clear()
            }
            accumulator = operand
            internalProgram.append(operand as AnyObject)
        }
    }
    
    func setOperand(variableName: String) {
        if !isPartialResult {
            clear()
        }
        accumulator = variableValues[variableName] ?? 0.0
        currentVariable = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    var variableValues: Dictionary<String, Double> = [:] {
        didSet {
            // Re-run the current program with the new value
            program = internalProgram as PropertyList
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "sin" : Operation.UnaryOperation({ __sinpi($0/180.0) }),
        "cos" : Operation.UnaryOperation({ __cospi($0/180.0) }),
        "tan" : Operation.UnaryOperation({ __tanpi($0/180.0) }),
        "x²" : Operation.UnaryOperation({ pow($0, 2) }),
        "√" : Operation.UnaryOperation(sqrt),
        "%" : Operation.UnaryOperation({ $0 / 100.0 }),
        "±" : Operation.UnaryOperation({ -$0 }),
        "log" : Operation.UnaryOperation({ log($0) }),
        "ln" : Operation.UnaryOperation({ log($0)/log(M_E) }),
        "10ⁿ" : Operation.UnaryOperation({ pow(10, $0) }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "xⁿ" : Operation.BinaryOperation(pow),
        "ⁿ√" : Operation.BinaryOperation({ pow($0, (1 / $1)) }),
        "=" : Operation.Equals,
        "AC" : Operation.Cancel
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Cancel
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let constantValue):
                updateDescriptionConstant(symbol: symbol)
                accumulator = constantValue
            case .UnaryOperation(let function):
                updateDescriptionUnary(symbol: symbol)
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation();
                // Default constructor for a struct is one which takes all its vars
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                updateDescriptionBinary(symbol: symbol)
            case .Equals:
                executePendingBinaryOperation();
            case .Cancel:
                clear()
                variableValues.removeAll()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            if description!.hasSuffix(" ") {
                description!.append(currentOperand)
            }
            accumulator = pending!.execute(secondOperand: accumulator)
            pending = nil;
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    // struct in Swift is very like class, but it is passed by value not by reference
    // also structs have no inheritance
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        func execute(secondOperand: Double) -> Double {
            return binaryFunction(firstOperand, secondOperand)
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            // Because this is an array (and therefore a value type) this returns a copy
            // We therefore don't need to worry about external clients changing anything in here as our internal
            // copy will remain as is
            return internalProgram as PropertyList
        }
        set {
            clear()
            let arrayOfOps = newValue as? [AnyObject] ?? [AnyObject]()
            for op in arrayOfOps {
                if let operand = op as? Double {
                    setOperand(operand: operand)
                } else if let storedString = op as? String {
                    // Assume that variable names are unique from operator symbols
                    if operations.keys.contains(storedString) {
                        performOperation(symbol: storedString)
                    } else {
                        setOperand(variableName: storedString)
                    }
                }
            }
        }
    }
    
    private func clear() {
        accumulator = 0.0
        pending = nil
        description = nil
        internalProgram.removeAll()
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String?
    
    private func updateDescriptionConstant(symbol: String) {
        if isPartialResult {
            description?.append(symbol)
        } else {
            description = symbol
        }
    }
    
    private func updateDescriptionUnary(symbol: String) {
        if (description == nil) {
            description = symbol + inParentheses(word: currentOperand)
        } else {
            if isPartialResult {
                description!.append(symbol + inParentheses(word: currentOperand))
            } else {
                description = symbol + inParentheses(word: description!)
            }
        }
    }
    
    private func updateDescriptionBinary(symbol: String) {
        if description == nil {
            description = currentOperand + " "
        } else {
            if !description!.hasSuffix(" ") {
                description!.append(" ")
            }
            if symbol == "×" || symbol == "÷" || symbol == "xⁿ" {
                description = inParentheses(word: description!.trimmingCharacters(in: .whitespaces))
            }
        }
        description!.append(symbol + " ")
    }
    
    private func inParentheses(word: String) -> String {
        return "(" + word + ")"
    }
    
    private func inParentheses(value: Double) -> String {
        return inParentheses(word: value.cleanValue)
    }
}
