//
//  GraphViewController.swift
//  Calculator
//
//  Created by Pete Bounford on 11/02/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    var pointsPerUnit: CGFloat = 10.0 { didSet { updateUI() } }
    
    var origin: CGPoint? { didSet { updateUI() } }
    
    var function: CalculatorBrain.PropertyList? { didSet { updateUI() } }
    
    var trigSetting = CalculatorBrain.TrigUnit.Degrees { didSet { updateUI() } }
    
    // MARK: - Model
    
    private var brain = CalculatorBrain()
    
    // MARK: - View
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.changeScale(_:))
            ))
            let doubleTapHandler = UITapGestureRecognizer(
                target: graphView, action: #selector(GraphView.setOrigin(_:))
            )
            doubleTapHandler.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapHandler)
            
            let panHandler = UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.moveOrigin(_:)
                ))
            panHandler.minimumNumberOfTouches = 1
            panHandler.maximumNumberOfTouches = 1
            graphView.addGestureRecognizer(panHandler)
            
            updateUI()
        }
    }
    
    private func updateUI() {
        if graphView != nil {
            brain.trigSetting = trigSetting
            graphView.pointsPerUnit = pointsPerUnit
            graphView.origin = origin
            if let program = function {
                graphView.functionOfX = { [weak weakSelf = self] in
                    weakSelf?.brain.variableValues["A"] = Double($0)
                    weakSelf?.brain.program = program
                    return weakSelf?.brain.result == nil ? nil : CGFloat((weakSelf?.brain.result)!)
                }
            }
        }
    }

}
