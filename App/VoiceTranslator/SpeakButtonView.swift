//
//  speakButtonView.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//  if tapgesture be called instead of the touchesEnded called , because of duplicate

import Foundation
import UIKit

enum ButtonViewStatus { //for controll out of uiview
    case normal // no any animation
    case loading // rotating the ring
    case recording //circl changeble
    case playing //after loading
}


protocol SpeakButtonViewDelegate: AnyObject {
    func buttonViewTapped(_ speakButtonView: SpeakButtonView)
}

@IBDesignable
class SpeakButtonView:UIView{
    // MARK: - Properties

    // Set the values of the ring in the storyboard
    @IBInspectable var ringColor: UIColor = Colors.primaryContainer {
        didSet {setNeedsDisplay()}}
    
    @IBInspectable var gapAngle: CGFloat = 30.0 {
          didSet {setNeedsDisplay()}}
    
    @IBInspectable var circleColor: UIColor = Colors.onPrimary {
          didSet {setNeedsDisplay()}}
    
    // status for update the button ui animation.
    var status:ButtonViewStatus = .normal {
        didSet {updateUIForStatus()}}
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
        
    // normal default . normal - speak . speak - loading. loading - speak, speak - normal.
    func updateUIForStatus(){
        switch status {
        case .normal:
                   // Update UI for normal state
                   print("Normal button")
                   // ... (additional updates)
        case .loading:
                   // Update UI for loading state
            print("loading button")
                   // ... (additional updates)
        case .recording:
                   // Update UI for recording state
            print("recording button")
                   // ... (additional updates)
        case .playing:
            print("playing buttong")
        }
    }

        // MARK: - Rotating animation Method
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
        if isRotating{
            layer.removeAnimation(forKey: "rotationAnimation")
            isRotating = false
        }
            // Optionally, perform any other cleanup or adjustments after stopping the rotation
    }
    
    
    // MARK: - Touch Gesture Handler
    private var originalRingColor: UIColor!
    weak var delegate: SpeakButtonViewDelegate?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            // Touch down, save the original ring color and change transparency
        if status == .normal{
            originalRingColor = ringColor
            ringColor = ringColor.withAlphaComponent(0.5)
        }
     
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            // Touch up, restore the original ring color
      // only call when normal, recording
        if (status == .normal || status == .recording){
            ringColor = originalRingColor
            delegate?.buttonViewTapped(self)
        }
           
        
    }
    
    
    // MARK: -  Circle Animation
    // Property to control circle visibility
    
    private var circleLayer: CALayer!
    var isCircling=false
    private func showChangeableCircle() {
        isCircling=true
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
        if isCircling{
           // Animate the circle's disappearance
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.0
        scaleAnimation.duration = 0.3
       // scaleAnimation.delegate = self
        circleLayer.add(scaleAnimation, forKey: "circleScaleAnimation")
            isCircling=false
        }
    }
    
    
    
}
