//
//  KevinView.swift
//
//  Created by Duncan Stothers.
//

import UIKit

class KevinView: UIView {
    
    @IBInspectable var width: CGFloat = 0.5
    @IBInspectable var color: UIColor = UIColor.white
    var notThinking: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let horizontalStep = frame.width / CGFloat(17)
        let verticalStep = frame.height / CGFloat(15)
        let bottomStep = frame.width / CGFloat(10)
        let kevFaceCenter = CGPoint(x: frame.width / CGFloat(2), y: frame.height * CGFloat(0.4))
        let kevFaceStep = CGFloat(8)
        
        let edgePath = UIBezierPath()
        edgePath.lineWidth = width
        
        //Draw neurons
        for i in 1...16 {
            drawCircle(midPoint: CGPoint(x: horizontalStep * CGFloat(i), y: verticalStep * CGFloat(13)), radius: 3, color: UIColor.white)
        }
        
        for i in 1...16 {
            drawCircle(midPoint: CGPoint(x: horizontalStep * CGFloat(i), y: verticalStep * CGFloat(10)), radius: 3, color: UIColor.white)
        }
        
        drawCircle(midPoint: CGPoint(x: frame.width / CGFloat(2), y: verticalStep * CGFloat(8)), radius: 3, color: UIColor.white)
        
        //Draw lines from input to layer 1
        for i in 1...9 {
            for j in 1...16 {
                edgePath.move(to: CGPoint(x: bottomStep * CGFloat(i), y: frame.height))
                edgePath.addLine(to: CGPoint(x: horizontalStep * CGFloat(j), y: verticalStep * CGFloat(13)))
            }
        }
        
        //Draw lines from layer 1 to 2
        for i in 1...16 {
            for j in 1...16 {
                edgePath.move(to: CGPoint(x: horizontalStep * CGFloat(i), y: verticalStep * CGFloat(13)))
                edgePath.addLine(to: CGPoint(x: horizontalStep * CGFloat(j), y: verticalStep * CGFloat(10)))
            }
        }
        
        //Draw lines from layer 2 to 3
        for i in 1...16 {
            edgePath.move(to: CGPoint(x: horizontalStep * CGFloat(i), y: verticalStep * CGFloat(10)))
            edgePath.addLine(to: CGPoint(x: frame.width / CGFloat(2), y: verticalStep * CGFloat(8)))
        }
        
        //Draw Kevin's eyes
        drawCircle(midPoint: CGPoint(x: kevFaceCenter.x - kevFaceStep, y: kevFaceCenter.y - kevFaceStep), radius: 2, color: UIColor.white)
        
        drawCircle(midPoint: CGPoint(x: kevFaceCenter.x + kevFaceStep, y: kevFaceCenter.y - kevFaceStep), radius: 2, color: UIColor.white)
        drawCircle(midPoint: CGPoint(x: kevFaceCenter.x + CGFloat(2) * kevFaceStep, y: kevFaceCenter.y - kevFaceStep), radius: 2, color: UIColor.white)
        drawCircle(midPoint: CGPoint(x: kevFaceCenter.x - CGFloat(2) * kevFaceStep, y: kevFaceCenter.y - kevFaceStep), radius: 2, color: UIColor.white)
        
        if notThinking {
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x - CGFloat(2) * kevFaceStep, y: kevFaceCenter.y - CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x + CGFloat(2) * kevFaceStep, y: kevFaceCenter.y - CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x - kevFaceStep, y: kevFaceCenter.y - CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x + kevFaceStep, y: kevFaceCenter.y - CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
            }
        
        //Draw Kevin's mouth
        drawCircle(midPoint: CGPoint(x: kevFaceCenter.x, y: kevFaceCenter.y + CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
        drawCircle(midPoint: CGPoint(x: kevFaceCenter.x + kevFaceStep, y: kevFaceCenter.y + CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
        drawCircle(midPoint: CGPoint(x: kevFaceCenter.x - kevFaceStep, y: kevFaceCenter.y + CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
        
        if notThinking {
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x + CGFloat(2) * kevFaceStep, y: kevFaceCenter.y + kevFaceStep), radius: 2, color: UIColor.white)
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x - CGFloat(2) * kevFaceStep, y: kevFaceCenter.y + kevFaceStep), radius: 2, color: UIColor.white)
        }
        
        if notThinking == false {
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x + CGFloat(2) * kevFaceStep, y: kevFaceCenter.y + CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
            drawCircle(midPoint: CGPoint(x: kevFaceCenter.x - CGFloat(2) * kevFaceStep, y: kevFaceCenter.y + CGFloat(2) * kevFaceStep), radius: 2, color: UIColor.white)
        }
        
        color.setStroke()
        edgePath.stroke()
        
    }
    
    func drawCircle(midPoint: CGPoint, radius: CGFloat, color: UIColor) {
        let circlePath = UIBezierPath(arcCenter: midPoint, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        color.setStroke()
        circlePath.stroke()
        color.setFill()
        circlePath.fill()
    }
}
