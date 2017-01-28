//
//  ViewController.swift
//  Calculator
//
//  Created by Pete Bounford on 27/01/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    
    var userIsInMiddleOfTyping = false

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInMiddleOfTyping {
            display.text?.append(digit)
        } else if digit != "0" {
            display.text = digit
            userIsInMiddleOfTyping = true
        }
    }
}

