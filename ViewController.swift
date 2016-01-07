//
//  ViewController.swift
//  Calculator
//
//  Created by Christian Morte on 12/12/15.
//  Copyright (c) 2015 Christian Morte. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController
{
    @IBOutlet weak var historyDisplay: UILabel!
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTyping = false
    var historyList = Array<String>()
    
    let historyListMaxCount = 10
    
    let model = CalculatorModel()
    
    
    @IBAction func debug() {
        model.debug()
    }
    
    @IBAction func clear() {
        historyList.removeAll()
        model.clear()
        display.text = "0"
        historyDisplay.text = "None"
        userIsInTheMiddleOfTyping = false
    }
    
    
    
    func addToHistoryList(stringtoBeAdded : String) {
        let lastIndex = historyList.count-1
        
        if userIsInTheMiddleOfTyping {
            historyList[lastIndex] += stringtoBeAdded
        } else {
            historyList.append(stringtoBeAdded)
        }
        
        if historyList.count == historyListMaxCount {
            historyList.removeAtIndex(0)
        }
    }
    
    func historyListToString(historyArray : Array<String>) -> String {
        var result = String()
        for action in historyArray {
            result += action + "  "
        }
        return result
    }
    
    @IBAction func appendDot() {
        let displayDoesNotHaveDot = display.text!.rangeOfString(".") == nil
        if userIsInTheMiddleOfTyping {
            if displayDoesNotHaveDot {
                display.text = display.text! + "."
                addToHistoryList(".")
            }
        }
        else{
            display.text = "0."
            addToHistoryList(" 0.")
        }
        userIsInTheMiddleOfTyping = true
        
    }
    
    @IBAction func appendDigit(sender: UIButton) /* -> (return type) */ {
        let digit = sender.currentTitle! // const local variable
        
        if digit == "∏" {
            addToHistoryList("∏")
        }
        else {
            addToHistoryList(digit)
        }
        
        if userIsInTheMiddleOfTyping {
            if digit == "∏" {
                enter()
                display.text = "\(M_PI)"
                enter()
            } else {
                display.text = display.text! + digit
            }
        }
        else {
            userIsInTheMiddleOfTyping = true
            if digit == "∏" {
                display.text = "\(M_PI)"
                enter()
            } else {
            display.text = digit
            }
        }
    }

    @IBAction func operation(sender: UIButton) {
        let operationSign = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            enter()
        }
        addToHistoryList(operationSign)
        historyDisplay.text = historyListToString(historyList)
        if let operationSign = sender.currentTitle {
            if let result = model.performOperation(operationSign) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }


//    func performOperation (operation: (Double, Double) -> Double){
//        if (operandStack.count >= 2){
//            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
//            enter()
//        }
//    }
//    
//    func performOperation (operation: Double -> Double){
//        if (operandStack.count >= 1){
//            displayValue = operation(operandStack.removeLast())
//            enter()
//        }
//    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTyping = false
        historyDisplay.text = historyListToString(historyList)
        if let result = model.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    var displayValue : Double? {
        get{
            if display.text! == "Insufficient" {
                return 0
                
            }
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            if newValue == nil {
                display.text = "Insufficient"
            } else {
                display.text = "\(newValue!)"
            }
            userIsInTheMiddleOfTyping = false
        }
    }
}

