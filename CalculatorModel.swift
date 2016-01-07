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
    var variableValues = [String:Double]()
    var description: String {
        get {
            var result = String()
            var opEvaluation = evaluateString(opStack)
            while let toAdd = opEvaluation.result {
                result = toAdd + ", " + result
                opEvaluation = evaluateString(opEvaluation.remainingOps)
            }
            
            if !result.isEmpty {
                result = dropLast(result)
                result = dropLast(result)
            } else {
                result += " "
            }
            return result
        }
    }
    
    private enum Op : Printable {
        case Pi
        case Variable(String)
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description : String {
            get {
                switch(self) {
                case Pi:
                    return "∏"
                case .Variable(let symbol):
                    return symbol
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
    
    private func needsParenthesis(operation: String) -> Bool {
        for (symbol, op) in knownOps {
            if operation.rangeOfString(symbol) != nil {
                switch (op) {
                case .BinaryOperation:  return true
                default: break
                }
            }
        }
        return false
    }
    
    private func operationString(firstOperand op1: String, secondOperand op2: String, operation op: String) -> String {
        if needsParenthesis(op2) {
            return "\(op1)\(op)(\(op2))"
        }
        return "\(op1)\(op)\(op2)"
    }
    
    private func operandString(operand: Double) -> String {
        let operandInt = Int(operand)
        if (Double(operandInt) == operand) {
            return "\(operandInt)"
        }
        return "\(operand)"
    }
    
    private func evaluateString(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch (op) {
            case .Pi:
                return ("∏", remainingOps)

            case .Variable(let symbol):
                return (symbol, remainingOps)
                
            case .Operand(let operand):
                return ("\(operandString(operand))", remainingOps)
                
            case .UnaryOperation(let operation, _):
                let opEvaluation = evaluateString(remainingOps)
                
                if let firstNum = opEvaluation.result {
                    return ("\(operation)(\(firstNum))", opEvaluation.remainingOps)
                }
                return ("\(operation)(?)", opEvaluation.remainingOps)
                
            case .BinaryOperation(let operation, _):
                let op1Evaluation = evaluateString(remainingOps)
                
                if let secondNum = op1Evaluation.result {
                    let op2Evaluation = evaluateString(op1Evaluation.remainingOps)
                    
                    if let firstNum = op2Evaluation.result {
                        
                        return (operationString(firstOperand: firstNum, secondOperand: secondNum, operation: operation), op2Evaluation.remainingOps)
                    }
                    
                    return (operationString(firstOperand: "?", secondOperand: secondNum, operation: operation), op2Evaluation.remainingOps)
                }
            }
        }
        return (nil, ops)
    }

    
    private func evaluate(ops: [Op]) -> (result : Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch (op) {
            case .Pi:
                return (M_PI, remainingOps)
            case .Variable(let symbol):
                if let operand = variableValues[symbol] {
                    return (operand, remainingOps)
                }
                return (nil, remainingOps)
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
    
    func setVariable(symbol: String, variable: Double) -> Double? {
        variableValues[symbol] = variable
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushPi() -> Double? {
        opStack.append(Op.Pi)
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
