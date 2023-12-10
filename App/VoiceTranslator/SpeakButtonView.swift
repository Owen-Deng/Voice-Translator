//
//  speakButtonView.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation
import UIKit

@IBDesignable
class SpeakButtonView:UIView{
    // MARK: - Properties

        // Set the color of the ring in the storyboard
    @IBInspectable var ringColor: UIColor = Colors.primaryContainer {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var gapAngle: CGFloat = 30.0 {
          didSet {
              setNeedsDisplay()
          }
    }
    
    @IBInspectable var circleColor: UIColor = Colors.onPrimary {
          didSet {
              setNeedsDisplay()
          }
    }
    

        // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRingView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRingView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
   
    
    private func setupRingView() {
        backgroundColor = UIColor.clear
    }
    

        // MARK: - Private Methods
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2.5
        let startAngle: CGFloat = -CGFloat.pi / 2
        let endAngle: CGFloat = startAngle + 2 * CGFloat.pi - gapAngle * CGFloat.pi / 180.0

        // Draw the ring
        let ringPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ringColor.setStroke()
        ringPath.lineWidth = 10.0
        ringPath.stroke()
    }
        

        // MARK: - Public Method
    private var ringLayer: CAShapeLayer = CAShapeLayer()
    
    private var isRotating = false
    func performRotationAnimation() {
        isRotating=true
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 2.0
        rotationAnimation.repeatCount = .infinity
        layer.add(rotationAnimation, forKey: "rotationAnimation")
        // Schedule a task to stop the rotation after 5 seconds (adjust as needed)
 
    }
    
    func stopRotationAnimation() {
            // Stop the rotation animation
        layer.removeAnimation(forKey: "rotationAnimation")
        isRotating = false

            // Optionally, perform any other cleanup or adjustments after stopping the rotation
    }
    
    
    // MARK: - Touch Gesture Handler
    private var originalRingColor: UIColor!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            // Touch down, save the original ring color and change transparency
        originalRingColor = ringColor
        ringColor = ringColor.withAlphaComponent(0.5)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            // Touch up, restore the original ring color
        ringColor = originalRingColor
    }
    
    
    // MARK: - Changeable Circle Animation
    // Property to control circle visibility
     var isCircleVisible: Bool = false {
         didSet {
             if isCircleVisible {
                 showChangeableCircle()
             } else {
                 hideChangeableCircle()
             }
         }
    }
    
    private var circleLayer: CALayer!
    private func showChangeableCircle() {
        // Use half of the smaller dimension as the radius
        let smallerDimension = min(bounds.width, bounds.height)
        let ringRadius = smallerDimension / 2.0
           // Create the circle layer
        circleLayer = CALayer()
        circleLayer.bounds = CGRect(x: 0, y: 0, width: 2 * ringRadius, height: 2 * ringRadius)
        circleLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        circleLayer.cornerRadius = ringRadius
        circleLayer.backgroundColor = circleColor.cgColor

           // Add the circle layer to the view's layer
        // Insert the circle layer below the ring layer
        if let ringLayer = layer.sublayers?.first {
            layer.insertSublayer(circleLayer, below: ringLayer)
        } else {
            layer.addSublayer(circleLayer)
        }

           // Animate the circle's radius
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = 0.3
        circleLayer.add(scaleAnimation, forKey: "circleScaleAnimation")
    }

    private func hideChangeableCircle() {
           // Animate the circle's disappearance
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.0
        scaleAnimation.duration = 0.3
       // scaleAnimation.delegate = self
        circleLayer.add(scaleAnimation, forKey: "circleScaleAnimation")
    }
    
    
    
}
