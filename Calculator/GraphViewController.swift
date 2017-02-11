//
//  GraphViewController.swift
//  Calculator
//
//  Created by Pete Bounford on 11/02/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    var scale = 1.0 { didSet { updateUI() } }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if graphView != nil {
            graphView.scale = CGFloat(scale)
        }
    }
}
