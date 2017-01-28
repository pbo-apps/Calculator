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
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "sin" : Operation.UnaryOperation({ __sinpi($0/180.0) }),
        "cos" : Operation.UnaryOperation({ __cospi($0/180.0) }),
        "tan" : Operation.UnaryOperation({ __tanpi($0/180.0) }),
        "√" : Operation.UnaryOperation(sqrt),
        "±" : Operation.UnaryOperation({ -$0 }),
        "%" : Operation.UnaryOperation({ $0 / 100.0 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "xⁿ" : Operation.BinaryOperation(pow),
        "ⁿ√" : Operation.BinaryOperation({ pow($0, (1 / $1)) }),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
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
    private struct PendingBinaryOperationInfo {
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
