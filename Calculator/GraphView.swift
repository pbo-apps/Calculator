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
    var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineColor = UIColor.green { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var axesColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    private var triangleSideLength: CGFloat {
        return min(bounds.size.width, bounds.size.height) * scale
    }
    private var triangleCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    private var triangleInternalAngle: CGFloat {
        return CGFloat(M_PI / 3.0)
    }
    
    private var defaultOrigin: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var axesDrawer = AxesDrawer()
    
    private func drawAxes(in rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = axesColor
        axesDrawer.drawAxes(in: rect, origin: origin ?? defaultOrigin, pointsPerUnit: scale)
    }
    
    private func pathForEquilateralTriangle(withCenter center: CGPoint, andSideLength sideLength: CGFloat) -> UIBezierPath {
        let centerToPoint = (sideLength / 2) / cos(triangleInternalAngle / 2)
        let centerToEdge = centerToPoint * sin(triangleInternalAngle / 2)
        let topPoint = CGPoint(x: center.x, y: center.y - centerToPoint)
        let rightPoint = CGPoint(x: center.x + (sideLength / 2), y: center.y + centerToEdge)
        let leftPoint = CGPoint(x: center.x - (sideLength / 2), y: center.y + centerToEdge)
        
        let path = UIBezierPath()
        path.move(to: topPoint)
        path.addLine(to: rightPoint)
        path.addLine(to: leftPoint)
        path.close()
        path.lineWidth = lineWidth
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        lineColor.set()
        pathForEquilateralTriangle(withCenter: triangleCenter, andSideLength: triangleSideLength).stroke()
        drawAxes(in: rect)
    }

}
