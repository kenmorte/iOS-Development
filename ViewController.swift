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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTyping = false
    let model = CalculatorModel()
    
    @IBAction func backspace() {
        if let currentDisplay = display.text {
            if !currentDisplay.isEmpty {
                display.text = dropLast(currentDisplay)
                
                if display.text!.isEmpty {
                    display.text = " "
                    displ
                }
            }
        }
    }

    @IBAction func setVar() {
        if let newVar = displayValue {
            displayValue = model.setVariable("M", variable: newVar)
        }
        userIsInTheMiddleOfTyping = false
        
    }
    
    @IBAction func getVar() {
        enter()
        displayValue = model.pushOperand("M")
    }

    
    @IBAction func clear() {
        model.clear()
        model.variableValues = [String:Double]()
        display.text = "0"
        descriptionLabel.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func appendDot() {
        let displayDoesNotHaveDot = display.text!.rangeOfString(".") == nil
        if userIsInTheMiddleOfTyping {
            if displayDoesNotHaveDot {
                display.text = display.text! + "."
            }
        }
        else {
            display.text = "0."
        }
        userIsInTheMiddleOfTyping = true
        
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
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
        if let operationSign = sender.currentTitle {
            if let result = model.performOperation(operationSign) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        descriptionLabel.text = model.description + " ="
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTyping = false
        if let result = displayValue {
            if display.text == "\(M_PI)" {
                displayValue = model.pushPi()
            } else {
                displayValue = model.pushOperand(result)
            }
        } else {
            displayValue = nil
        }
    }
    
    var displayValue : Double? {
        get{
            if display.text! == " " {
                return 0
                
            }
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            if newValue == nil {
                display.text = " "
            } else {
                display.text = "\(newValue!)"
            }
            userIsInTheMiddleOfTyping = false
        }
    }
}

