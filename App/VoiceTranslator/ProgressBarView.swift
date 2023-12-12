//
//  ProgressBarView.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation
import UIKit

@IBDesignable
class ProgressBarView:UIView{
    @IBInspectable var progressValue: CGFloat = 0.0 { //from 0 to 20
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
    
    private let progressLayer=CALayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        layer.addSublayer(progressLayer)

    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if visible{
            let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progressValue/20, height: rect.height))
            progressLayer.frame = progressRect
            progressLayer.backgroundColor = lineColor.cgColor
        }
    }
    
    func setProgress(value: CGFloat) {
            progressValue = value
    }
}
