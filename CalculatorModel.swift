//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Christian Morte on 12/24/15.
//  Copyright (c) 2015 Christian Morte. All rights reserved.
//

import Foundation

class CalculatorModel
{
    private var knownOps = [String: Op]()
    private var opStack = [Op]()
    
    private enum Op : Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description : String {
            get {
                switch(self) {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    init() {
        func addBinOp(symbol: String, operation: (Double, Double) -> Double){
            knownOps[symbol] = Op.BinaryOperation(symbol, operation)
        }
        
        func addUnOp(symbol: String, operation: Double -> Double) {
            knownOps[symbol] = Op.UnaryOperation(symbol, operation)
        }
        addBinOp("∗", *)
        addBinOp("+", +)
        addBinOp("-") { $1 - $0 }
        addBinOp("⌹") { $1 / $0 }
        addUnOp("√", sqrt)
        addUnOp("sin", sin)
        addUnOp("cos", cos)
    }
    
    func debug () {
        println (knownOps)
    }
    
    private func evaluate(ops: [Op]) -> (result : Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch (op) {
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                return (nil, remainingOps)
                
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll()
    }
}
