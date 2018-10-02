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
    @IBOutlet weak var velocityLabel: UILabel!
    
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
    
    var dotView = UIView()
    func removeDot() {
        for subview in view.subviews {
            if subview.tag == 9 { subview.removeFromSuperview() }
        }
    }
    
    //MARK: - Pan Handler
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)
        
        switch recognizer.state {
        case .began:
            removeDot()
//            animator = UIViewPropertyAnimator()
            
            //Create Dot
            dotView = UIView(frame: CGRect(x: recognizer.location(in: view).x, y: recognizer.location(in: view).y, width: 20, height: 20))
            dotView.frame.origin = CGPoint(x: dotView.frame.origin.x - dotView.frame.width / 2, y: dotView.frame.origin.y - dotView.frame.height / 2)
            dotView.backgroundColor = .black
            dotView.layer.cornerRadius = dotView.frame.height / 2
            
            //Add Tag To Register It
            dotView.tag = 9
            view.addSubview(dotView)
            return
        case .changed:
            //Add Dot To Touch Location
            dotView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            //Change View's Transform
            main.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            
            let velocity = CGVector(
                dx: relativeVelocity(forVelocity: recognizer.velocity(in: view).x, from: translation.x, to: 0),
                dy: relativeVelocity(forVelocity: recognizer.velocity(in: view).y, from: translation.y, to: 0)
            )
            velocityLabel.text = "Velocity X: \(CGFloat(Int(recognizer.velocity(in: view).x * 100)) / 100), Y: \(CGFloat(Int(recognizer.velocity(in: view).y * 100)) / 100) \n Relative Velocity X: \(CGFloat(Int(velocity.dx * 100)) / 100), Y: \(CGFloat(Int(velocity.dy * 100)) / 100)"
            debug("Pan Velocity: \(recognizer.velocity(in: view))")
        case .ended, .cancelled:
            removeDot()
            
            //Create Relative Velocity Vector
            let velocity = CGVector(
                dx: relativeVelocity(forVelocity: recognizer.velocity(in: view).x, from: translation.x, to: 0),
                dy: relativeVelocity(forVelocity: recognizer.velocity(in: view).y, from: translation.y, to: 0)
            )
            
            let springParameters = UISpringTimingParameters(damping: CGFloat(dampingSlider!.value), response: CGFloat(responseSlider!.value), initialVelocity: velocity)
            
            animator = UIViewPropertyAnimator(duration: 0, timingParameters: springParameters)
            animator.addAnimations {
                self.main.transform = .identity
            }
            
            animator.startAnimation()
            
            debug("Relative Velocity: \(velocity)")
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

