//
//  ViewController.swift
//  Calculator
//
//  Created by Pete Bounford on 27/01/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        print("Touched digit number \(digit)")
    }
}

