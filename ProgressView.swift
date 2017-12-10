//
//  ProgressView.swift
//  DISourceryTest
//
//  Created by Jordan.Dixon on 09/12/2017.
//  Copyright © 2017 Jordan.Dixon. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressView: UIView {
    
    @IBInspectable var trackColor: UIColor = .lightGray { didSet { setNeedsDisplay() } }
    @IBInspectable var progressColor: UIColor = .darkGray { didSet { setNeedsDisplay() } }
    @IBInspectable var lineWidth: CGFloat = 10 { didSet { setNeedsDisplay() } }
    
    /// Gets called each time the current progress change animation finishes
    var animationDidFinish: (() -> Void)?
    
    /// Should be set to a value between 0.0 and 100.0
    var progress = 0.0 { didSet { updateProgress(from: oldValue, to: progress) } }
    
    private var progressLayer = CAShapeLayer()
    private var trackConfiguration: PathConfiguration {
        return PathConfiguration(color: trackColor, lineWidth: lineWidth, startAngle: -CGFloat.pi / 2, type: .track)
    }
    private var progressConfiguration: PathConfiguration {
        return PathConfiguration(color: progressColor, lineWidth: lineWidth, startAngle: -CGFloat.pi / 2, type: .progress)
    }
}

// MARK: - View Drawing
extension ProgressView {
    
    override func draw(_ rect: CGRect) {
        
        let trackLayer = CAShapeLayer()
        trackLayer.drawCircle(in: rect, with: trackConfiguration)
        self.layer.addSublayer(trackLayer)
        
        progressLayer.drawCircle(in: rect, with: progressConfiguration)
        self.layer.addSublayer(progressLayer)
    }
    
    private func updateProgress(from oldValue: Double, to newValue: Double, duration: CFTimeInterval = 0.2) {
        
        let animation = CABasicAnimation(keyPath: StrokePosition.strokeEnd.rawValue)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = oldValue < 0 ? 0 : oldValue / 100
        animation.toValue = newValue > 100 ? 100 : newValue / 100
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        progressLayer.removeAnimation(forKey: StrokePosition.strokeEnd.rawValue)
        progressLayer.add(animation, forKey: StrokePosition.strokeEnd.rawValue)
    }
    
}

extension ProgressView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationDidFinish?()
    }
}
