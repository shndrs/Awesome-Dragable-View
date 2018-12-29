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
    
    let dViewHeight:CGFloat = 500
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
            
            let translation = recognizer.translation(in: self.dViewController.handleArea)
            var fractionComplete = translation.y / dViewHeight
            fractionComplete = DViewVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete )
            
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded(state:DViewState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                
                guard let self = self else { return }
                
                switch state {
                    
                case .expanded:
                    self.dViewController.view.frame.origin.y = self.view.frame.height - self.dViewHeight
                case .collapsed:
                    self.dViewController.view.frame.origin.y = self.view.frame.height - self.dViewHandleAreaHeight
                }
            }
            
            frameAnimator.addCompletion { [weak self] _ in
                
                guard let self = self else { return }
                
                self.DViewVisible = !self.DViewVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak self] in
                
                guard let self = self else { return }
                
                switch state {
                    
                case .expanded:
                    self.dViewController.view.layer.cornerRadius = 16
                case .collapsed:
                    self.dViewController.view.layer.cornerRadius = 8
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let self = self else { return }
                switch state {
                    
                case .expanded:
                    self.blurView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.blurView.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
        }
    }
    
    func startInteractiveTransition(state:DViewState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
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

