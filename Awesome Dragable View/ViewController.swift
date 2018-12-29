//
//  ViewController.swift
//  Awesome Dragable View
//
//  Created by Sahand Raeisi on 12/29/18.
//  Copyright © 2018 Sahand Raeisi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum DViewState {
        case expanded
        case collapsed
    }

    var dViewController:DragableViewController!
    var blurView:UIVisualEffectView!
    
    let dViewHeight:CGFloat = 600
    let dViewHandleAreaHeight:CGFloat = 65
    
    var DViewVisible = false
    var nextState:DViewState {
        return DViewVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrapted:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDragableView()
    }

    func setUpDragableView() {
        blurView = UIVisualEffectView()
        blurView.frame = self.view.frame
        self.view.addSubview(blurView)
        
        dViewController = DragableViewController(nibName:"DragableViewController", bundle:nil)
        self.addChild(dViewController)
        self.view.addSubview(dViewController.view)
        
        dViewController.view.frame = CGRect(x: 0,
                                            y: self.view.frame.height - dViewHandleAreaHeight,
                                            width: self.view.bounds.width,
                                            height: dViewHeight)
        dViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dragableViewTapHandler(recognizer:)))
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragableViewPanHandler(recognizer:)))
        
        dViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        dViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    @objc func dragableViewTapHandler(recognizer:UITapGestureRecognizer) {
        
    }

    @objc func dragableViewPanHandler(recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
            
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            updateInteractiveTransition(fractionCompleted: 0)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded(state:DViewState, duration:TimeInterval) {
        
    }
    
    func startInteractiveTransition(state:DViewState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrapted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrapted
        }
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

