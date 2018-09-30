//
//  ViewController.swift
//  Initial velocity problem
//
//  Created by Юрий Есин on 29.09.2018.
//  Copyright © 2018 Roman Esin. All rights reserved.
//

import UIKit

extension UISpringTimingParameters {
    
    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var main: UIView!
    var animator = UIViewPropertyAnimator()
    
    @IBOutlet weak var responseSlider: UISlider!
    @IBOutlet weak var dampingSlider: UISlider!
    
    private var isDebuggingEnabled = false
    
    func debug(_ value: Any) {
        if isDebuggingEnabled {
            print(value)
        }
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        //Turn On Debugging
        isDebuggingEnabled = true
        
        main.layer.cornerRadius = 20
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        main.addGestureRecognizer(panGesture)
        
    }
    
    //MARK: - Pan Handler
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)
        
        switch recognizer.state {
        case .began:
            return
        case .changed:
            //Change View's Transform
            main.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            debug("Pan Velocity: \(recognizer.velocity(in: view))")
            return
        case .ended, .cancelled:
            
            //Create Relative Velocity Vector
            let velocity = CGVector(
                dx: relativeVelocity(forVelocity: recognizer.velocity(in: view).x, from: translation.x, to: -translation.x),
                dy: relativeVelocity(forVelocity: recognizer.velocity(in: view).y, from: translation.y, to: -translation.x)
            )
            
            let springParameters = UISpringTimingParameters(damping: CGFloat(dampingSlider!.value), response: CGFloat(responseSlider!.value), initialVelocity: velocity)
            
            animator = UIViewPropertyAnimator(duration: 0, timingParameters: springParameters)
            animator.addAnimations {
                self.main.transform = .identity
            }
            
            animator.startAnimation()
            
            debug("Relative Velocity: \(velocity)")
            return
        default:
            return
        }
    }
    
    //MARK: - Relative Velocity
    private func relativeVelocity(forVelocity velocity: CGFloat, from currentValue: CGFloat, to targetValue: CGFloat) -> CGFloat {
        guard currentValue - targetValue != 0 else { return 0 }
        return velocity / (targetValue - currentValue)
    }
    
    //MARK: - Response Slider Func
    @IBAction func response(_ sender: UISlider) {
        
    }
    
    //MARK: - Damping Slider Func
    @IBAction func damping(_ sender: UISlider) {
        
    }
}

