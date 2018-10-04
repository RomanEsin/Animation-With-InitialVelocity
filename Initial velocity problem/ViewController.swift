//
//  ViewController.swift
//  Initial velocity problem
//
//  Created by Roman Esin on 29.09.2018.
//  Copyright © 2018 Roman Esin. All rights reserved.
//

import UIKit

extension UISpringTimingParameters {
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
        isDebuggingEnabled = false
        
        main.layer.cornerRadius = 20
        startOrigin = main.frame.origin
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        main.addGestureRecognizer(panGesture)
        
        velocityLabel.isHidden = true
    }
    
    //MARK: - Pan Handler And Additional Variables
    var startOrigin = CGPoint()
    var initialOffset = CGPoint.zero
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)
        let location = recognizer.location(in: view)
        
        switch recognizer.state {
        case .began:
            initialOffset = CGPoint(x: location.x - main.center.x, y: location.y - main.center.y)
            
        case .changed:
            //Change View's Position
            main.center = CGPoint(x: location.x - initialOffset.x, y: location.y - initialOffset.y)
            
        case .ended, .cancelled:
            //Create Relative Velocity Vector
            let velocity = CGVector(
                dx: relativeVelocity(forVelocity: recognizer.velocity(in: view).x, from: translation.x, to: 0),
                dy: relativeVelocity(forVelocity: recognizer.velocity(in: view).y, from: translation.y, to: 0)
            )
            
            let springParameters = UISpringTimingParameters(damping: CGFloat(dampingSlider!.value), response: CGFloat(responseSlider!.value), initialVelocity: velocity)
            
            animator = UIViewPropertyAnimator(duration: 0, timingParameters: springParameters)
            animator.addAnimations {
                self.main.frame.origin = self.startOrigin
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

