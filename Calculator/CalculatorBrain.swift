//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Pete Bounford on 28/01/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import Foundation

// Global function, like sqrt - is it internal or public though?
func add(op1: Double, op2: Double) -> Double {
    return op1 + op2
}
func subtract(op1: Double, op2: Double) -> Double {
    return op1 - op2
}
func divide(op1: Double, op2: Double) -> Double {
    return op1 / op2
}

class CalculatorBrain {
    
    // Type Double inferred from 0.0 (or indeed anyInt.anyInt)
    private var accumulator = 0.0;
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "sin" : Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan" : Operation.UnaryOperation(tan),
        "√" : Operation.UnaryOperation(sqrt),
        "+" : Operation.BinaryOperation(add),
        "-" : Operation.BinaryOperation(subtract),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation(divide),
        "=" : Operation.Equals
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let constantValue):
                accumulator = constantValue
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation();
                // Default constructor for a struct is one which takes all its vars
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation();
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.execute(secondOperand: accumulator)
            pending = nil;
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    // struct in Swift is very like class, but it is passed by value not by reference
    // also structs have no inheritance
    struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        func execute(secondOperand: Double) -> Double {
            return binaryFunction(firstOperand, secondOperand)
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
