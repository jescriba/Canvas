//
//  ViewController.swift
//  Canvas
//
//  Created by Joshua Escribano on 11/3/16.
//  Copyright © 2016 JoshuaMike. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    @IBOutlet weak var trayView: UIView!
    var trayOriginalCenter: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    var trayCenterWhenClosed: CGPoint!
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    var floatingFaceOriginalCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayCenterWhenClosed = trayView.center
        
        trayCenterWhenOpen = CGPoint(x:trayCenterWhenClosed.x,y:view.bounds.maxY - trayView.frame.height / 2)
        trayOriginalCenter = trayCenterWhenClosed
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onTrayTapGesture(_ sender: UITapGestureRecognizer) {
        if(trayView.center == trayCenterWhenClosed) {
            trayView.center = trayCenterWhenOpen
        } else {
            trayView.center = trayCenterWhenClosed
        }
    }
    
    @IBAction func onTrayPanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let point = panGestureRecognizer.location(in: view)
        let translation = panGestureRecognizer.translation(in: trayView)
        
        if panGestureRecognizer.state == .began {
            trayOriginalCenter = trayView.center
            print("Began \(point)")
        } else if panGestureRecognizer.state == .changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            print("Changed \(point)")
        } else if panGestureRecognizer.state == .ended {
            print("Ended \(point)")
            // If Moving down
            if (panGestureRecognizer.velocity(in:trayView).y > 0) {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: panGestureRecognizer.velocity(in: trayView).y, options: [], animations: {()->Void in
                        self.trayView.center = self.trayCenterWhenClosed
                    }, completion: nil)
                
            } else {
            // Moving down
                trayView.center = trayCenterWhenOpen
            }
        }
    }
    
    @IBAction func onFacePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        if sender.state == .began {
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            
            let newGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(didPanNewFace(sender:)))
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.addGestureRecognizer(newGestureRecognizer)
            
            let newPinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchFace(sender:)))
            newlyCreatedFace.addGestureRecognizer(newPinchRecognizer)
            
            let newRotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotateFace(sender:)))
            newRotationRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(newRotationRecognizer)
            
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
        } else if sender.state == .changed {
            let newCenter = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
            newlyCreatedFace.center = newCenter
        } else if sender.state == .ended {
            
        }
    }
    
    func didRotateFace(sender: UIRotationGestureRecognizer) {
        let face = sender.view as! UIImageView
        
        if sender.state == .began {
        
        } else if sender.state == .changed {
            var transform = face.transform
            transform = transform.rotated(by: sender.rotation)
            face.transform = transform
            sender.rotation = 0
        } else if sender.state == .ended {
        
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didPanNewFace(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let face = sender.view as! UIImageView
        if sender.state == .began {
            face.transform = CGAffineTransform(scaleX:1.3,y:1.3)
            
            floatingFaceOriginalCenter = face.center
        } else if sender.state == .changed {
            face.center = CGPoint(x:floatingFaceOriginalCenter.x + translation.x, y: floatingFaceOriginalCenter.y + translation.y)
        } else if sender.state == .ended {
            face.transform = CGAffineTransform(scaleX:1,y:1)
        }
    }
    
    func didPinchFace(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.scale = 1
        let face = sender.view as! UIImageView
        var transform = face.transform
        transform = transform.scaledBy(x:scale,y:scale)
        face.transform = transform
    }
}

