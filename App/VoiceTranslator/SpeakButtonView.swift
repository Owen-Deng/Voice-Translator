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
    
    // speaking and listenning 1 to 2/3
    @IBInspectable var circleScaleRate: CGFloat = 2/3 {
        didSet {
            if (status == .playing || status == .recording){
                setNeedsDisplay()
            }
        }}
    
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
        let radius = min(rect.width, rect.height) / 3
        let startAngle: CGFloat = -CGFloat.pi / 2
        let endAngle: CGFloat = startAngle + 2 * CGFloat.pi - gapAngle * CGFloat.pi / 180.0

        // Draw the ring
        let ringPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ringColor.setStroke()
        ringPath.lineWidth = 10.0
        ringPath.stroke()
        
        if (self.status == .recording || self.status == .playing) {
        //Draw the circle animation
        // Get the context for drawing
        guard let context = UIGraphicsGetCurrentContext() else { return }

               // Set the circle's properties (color, size, position)
        let circleSize = CGSize(width: bounds.width * circleScaleRate, height: bounds.height * circleScaleRate)
        let circlePosition = CGPoint(x: bounds.midX - circleSize.width / 2, y: bounds.midY - circleSize.height / 2)
        
               // Draw the circle
        context.setFillColor(circleColor.cgColor)
        context.setAlpha(0.5)
        context.fillEllipse(in: CGRect(origin: circlePosition, size: circleSize))
        }
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
            setNeedsDisplay()
            print("Loading button")
            performRotationAnimation()
                   // ... (additional updates)
        case .recording:
                   // Update UI for recording state
            print("Recording button")
                   // ... (additional updates)
        case .playing:
            stopRotationAnimation()
            print("Playing buttong")
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
        DispatchQueue.main.async {
           
            self.layer.removeAnimation(forKey: "rotationAnimation")
            self.isRotating = false
        
        }
        }
       
            // Optionally, perform any other cleanup or adjustments after stopping the rotation
    }
    
    
    // MARK: - Touch Gesture Handler
    private var originalRingColor: UIColor!
    weak var delegate: SpeakButtonViewDelegate?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            // Touch down, save the original ring color and change transparency
        if (status == .normal || status == .recording){
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
    
    
    
    
}
