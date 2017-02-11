//
//  GraphViewController.swift
//  Calculator
//
//  Created by Pete Bounford on 11/02/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    var scale = 10.0 { didSet { updateUI() } }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.changeScale(_:))
            ))
            updateUI()
        }
    }
    
    private func updateUI() {
        if graphView != nil {
            graphView.pointsPerUnit = CGFloat(scale)
        }
    }
}
