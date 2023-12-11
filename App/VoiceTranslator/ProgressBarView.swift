//
//  ProgressBarView.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation
import UIKit

class ProgressBarView:UIView{
    @IBInspectable var progressValue: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var visible : Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if visible{
            let progressWidth = (progressValue / CGFloat(20)) * bounds.width
            let progressPath = UIBezierPath()
            
            progressPath.lineWidth = lineWidth
            progressPath.lineCapStyle = .butt
            progressPath.move(to: CGPoint(x: 0, y: 0))
            progressPath.addLine(to: CGPoint(x: progressWidth, y: 0))
            lineColor.setStroke()
            progressPath.stroke()
        }
    }
    
    func setProgress(value: CGFloat) {
        if value >= 0.0 && value <= CGFloat(20) {
            progressValue = value
        }
    }
}
