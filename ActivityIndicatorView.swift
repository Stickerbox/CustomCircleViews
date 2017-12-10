//
//  ActivityIndicatorView.swift
//  DISourceryTest
//
//  Created by Jordan.Dixon on 09/12/2017.
//  Copyright © 2017 Jordan.Dixon. All rights reserved.
//

import UIKit

@IBDesignable
class ActivityIndicatorView: UIView {
    
    enum AnimationStyle {
        case linear, extendable
    }
    
    @IBInspectable var trackColor: UIColor = .clear { didSet { setNeedsDisplay() } }
    @IBInspectable var activityIndicatorColor: UIColor = .darkGray { didSet { setNeedsDisplay() } }
    @IBInspectable var lineWidth: CGFloat = 7 { didSet { setNeedsDisplay() } }
    
    /// The style of animation the view performs when animating
    var animationStyle: AnimationStyle = .extendable
    /// If true, the view hides itself when shouldAnimate is false
    var hidesWhenStopped = false
    /// Starts and stops the animation of the view. Visibility changes will occur repective to the hidesWhenStopped property.
    var shouldAnimate: Bool = true {
        didSet {
            if shouldAnimate {
                start()
            } else {
                stop()
            }
        }
    }
    
    private let activityLayer = CAShapeLayer()
    private var isAnimating = false
    private var timingFunction: CAMediaTimingFunction {
        return animationStyle == .extendable ? CAMediaTimingFunction(controlPoints: 0.2, 0.2, 0.5, 0.75) : CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    }
    private var trackConfiguration: PathConfiguration {
        return PathConfiguration(color: trackColor, lineWidth: lineWidth, startAngle: -CGFloat.pi, type: .track)
    }
    private var activityConfiguration: PathConfiguration {
        return PathConfiguration(color: activityIndicatorColor, lineWidth: lineWidth, startAngle: -CGFloat.pi, type: .custom(0.2))
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 65, height: 65)
    }
}

// MARK: - View Drawing
extension ActivityIndicatorView {
    
    override func draw(_ rect: CGRect) {
        let trackLayer = CAShapeLayer()
        trackLayer.drawCircle(in: rect, with: trackConfiguration)
        self.layer.addSublayer(trackLayer)
        
        activityLayer.drawCircle(in: rect, with: activityConfiguration)
        activityLayer.position = CGPoint(x: rect.maxX / 2, y: rect.maxY / 2)
        activityLayer.bounds = activityLayer.path!.boundingBox
        self.layer.addSublayer(activityLayer)
        addAnimation(to: activityLayer)
        if animationStyle == .extendable { transformPath(of: activityLayer, keyPath: .strokeStart) }
    }
    
    private func addAnimation(to layer: CAShapeLayer) {
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.duration = 1.0
        rotation.isRemovedOnCompletion = false
        rotation.repeatCount = Float.infinity
        rotation.fillMode = kCAFillModeForwards
        rotation.byValue = NSNumber(value: Double.pi * 2)
        rotation.timingFunction = timingFunction
        
        layer.add(rotation, forKey: "rotation")
    }
    
    private func transformPath(of layer: CAShapeLayer, keyPath: StrokePosition) {
        
        let transform = CABasicAnimation(keyPath: keyPath.rawValue)
        transform.duration = 1.0
        transform.isRemovedOnCompletion = false
        transform.repeatCount = 1
        transform.autoreverses = true
        transform.fillMode = kCAFillModeForwards
        transform.byValue = NSNumber(value: 0.15)
        transform.timingFunction = timingFunction
        transform.delegate = self
        
        layer.removeAnimation(forKey: keyPath.rawValue)
        layer.add(transform, forKey: keyPath.rawValue)
    }
}

// MARK: - View Interaction Functions
extension ActivityIndicatorView {
    
    private func pause(layer: CAShapeLayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        isAnimating = false
    }
    
    private func resume(layer: CAShapeLayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        
        isAnimating = true
    }
    
    private func stop() {
        if hidesWhenStopped { self.isHidden = true }
        pause(layer: activityLayer)
    }
    
    private func start() {
        if hidesWhenStopped { self.isHidden = false }
        resume(layer: activityLayer)
    }
}

// MARK: - CAAnimationDelegate
extension ActivityIndicatorView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim.value(forKeyPath: StrokePosition.strokeStart.rawValue) != nil {
            transformPath(of: activityLayer, keyPath: .strokeStart)
        } else {
            transformPath(of: activityLayer, keyPath: .strokeEnd)
        }
    }
}
