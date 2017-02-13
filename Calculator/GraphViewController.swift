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
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        if let storedOrigin = defaults.string(forKey: userDefaultsKeys.origin) {
            self.origin = CGPointFromString(storedOrigin)
        }
        let storedPointsPerUnit = defaults.float(forKey: userDefaultsKeys.pointsPerUnit)
        if storedPointsPerUnit > 0.0 {
            self.pointsPerUnit = CGFloat(storedPointsPerUnit)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let currentOrigin = graphView?.origin {
            defaults.set(NSStringFromCGPoint(currentOrigin), forKey: userDefaultsKeys.origin)
        }
        if let currentPointsPerUnit = graphView?.pointsPerUnit {
            defaults.set(currentPointsPerUnit, forKey: userDefaultsKeys.pointsPerUnit)
        }
        defaults.synchronize()
    }
    
    // MARK: - Model
    
    private var brain = CalculatorBrain()
    
    struct userDefaultsKeys {
        static let origin = "graph_origin"
        static let pointsPerUnit = "graph_points_per_unit"
    }
    
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
                    weakSelf?.brain.variableValues["x"] = Double($0)
                    weakSelf?.brain.program = program
                    return weakSelf?.brain.result == nil ? nil : CGFloat((weakSelf?.brain.result)!)
                }
            }
        }
    }

}
