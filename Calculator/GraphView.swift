//
//  GraphView.swift
//  Calculator
//
//  Created by Pete Bounford on 11/02/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    @IBInspectable
    var origin: CGPoint? { didSet { setNeedsDisplay() } }
    @IBInspectable
    var pointsPerUnit: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineColor: UIColor = UIColor.green { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var axesColor: UIColor = UIColor.black { didSet { setNeedsDisplay() } }

    var functionOfX: ((CGFloat) -> CGFloat?)? { didSet { setNeedsDisplay() } }
    
    func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            pointsPerUnit *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func setOrigin(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            origin = recognizer.location(in: self)
        default:
            break
        }
    }
    
    private var beginPanPoint: CGPoint?
    
    func moveOrigin(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            beginPanPoint = recognizer.translation(in: self)
        case .changed, .ended:
            let panPoint = recognizer.translation(in: self)
            translateOrigin(byX: panPoint.x - beginPanPoint!.x, andY: panPoint.y - beginPanPoint!.y)
            beginPanPoint = recognizer.state == .ended ? nil : panPoint
        default:
            beginPanPoint = nil
        }
    }
    
    private func translateOrigin(byX x: CGFloat, andY y: CGFloat) {
        origin = CGPoint(
            x: graphOrigin.x + x,
            y: graphOrigin.y + y
        )
    }
    
    private var graphOrigin: CGPoint {
        return origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private func pixel(at point: CGFloat) -> CGFloat {
        return point * contentScaleFactor
    }
    private func point(at pixel: CGFloat) -> CGFloat {
        return pixel / contentScaleFactor
    }
    
    private var axesDrawer = AxesDrawer()
    
    private func drawAxes(in rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = axesColor
        axesDrawer.drawAxes(in: rect, origin: graphOrigin, pointsPerUnit: pointsPerUnit)
    }
    
    private func pathForFunction(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        if let calculateY = functionOfX {
            path.lineWidth = lineWidth
            var dataPoint: CGPoint?
            
            for xPixel in stride(from: pixel(at: bounds.minX), to: pixel(at: bounds.maxX), by: 1.0) {
                let xPoint = point(at: xPixel)
                let xValue = (xPoint - graphOrigin.x) / pointsPerUnit
                if let yValue = calculateY(xValue) {
                    let yPoint = graphOrigin.y - (yValue * pointsPerUnit)
                    
                    if rect.contains(CGPoint(x: xPoint, y: yPoint)) {
                        if dataPoint == nil {
                            dataPoint = CGPoint(x: xPoint, y: yPoint)
                            path.move(to: dataPoint!)
                        } else {
                            dataPoint = CGPoint(x: xPoint, y: yPoint)
                            path.addLine(to: dataPoint!)
                        }
                    } else {
                        dataPoint = nil
                    }
                }
            }
        }
        return path
    }
    
    override func draw(_ rect: CGRect) {
        lineColor.set()
        pathForFunction(in: rect).stroke()
        drawAxes(in: rect)
    }

}
