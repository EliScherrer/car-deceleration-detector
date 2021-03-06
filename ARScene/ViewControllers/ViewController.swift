//
//  ViewController.swift
//  ARScene
//
//  Created by Samuel Carbone on 2/19/18.
//  Copyright © 2018 Samuel Carbone. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {

    var statusLabel:UILabel?
    var statusColor:UIColor = UIColor.white
    
    var pointerLabel:UILabel?
    
    //values for calculating acceleration
    var distances = [CGFloat?](repeating: nil, count: 15)
    var oldestDistance:CGFloat = 0.0
    var lastDistance:CGFloat = 0.0
    var currentDistance:CGFloat = 0.0
    
    var lastVelocity:CGFloat = 0.0
    var currentVelocity:CGFloat = 0.0
    
    var currentAcceleration:CGFloat = 0.0
    
    var totalTime:CGFloat = 0.0
    var timeInterval:CGFloat = 0.01
    var calcInterval:CGFloat = 0.1
    

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        //initialize the array of distances
        var i = 0
        while (i < 15) {
            distances[i] = 0.0
            i += 1
        }
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        statusLabel = UILabel(frame: CGRect.zero)
        statusLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        statusLabel?.textAlignment = .center
        statusLabel?.textColor = .white
        statusLabel?.frame = CGRect(x: 0, y: 16, width: view.bounds.width, height: 64)
        sceneView.addSubview(statusLabel!)

        
        // Show the X in the middle of the screen so the user knows what the distance is calculated for
        pointerLabel = UILabel(frame: CGRect.zero)
        pointerLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        pointerLabel?.textAlignment = .center
        pointerLabel?.textColor = .white
        pointerLabel?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 64)
        pointerLabel?.center = sceneView.center
        pointerLabel?.text = "x"
        
        sceneView.addSubview(pointerLabel!)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        sceneView.addGestureRecognizer(swipeLeft)
        
        
        Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(ViewController.distanceHandler), userInfo: nil, repeats: true)

    }
    
    func getFlashState(){
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = .auto // set on
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        //5
        var status = "Loading..."
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            status = "Not available"
        case ARCamera.TrackingState.limited(_):
            status = "Analyzing..."
        case ARCamera.TrackingState.normal:
            status = "Ready"
        }
        statusLabel?.text = status
    }
    
    
    @objc func distanceHandler(){
        self.getFlashState()
        let tapLocation = view.center
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let result = hitTestResults.first {
            
            //make sure to add the first distance
            if (totalTime == 0.0) {
                distances[0] = result.distance
            }
            totalTime += timeInterval   //update the total time
            
            //check for inacurate measurments
            if (abs(result.distance - distances[0]!) < 0.01) {
                
                //update the array of values
                var i = 0
                while (i < 14) {
                    distances[i + 1] = distances[i]
                    i += 1
                }
                distances[0] = result.distance
                
                if (totalTime > (timeInterval * 3)) {
                    
                    //update distances
                    oldestDistance = ((distances[14]! + distances[13]! + distances[12]! + distances[11]! + distances[10]!) / 5)
                    lastDistance = ((distances[9]! + distances[8]! + distances[7]! + distances[6]! + distances[5]!) / 5)
                    currentDistance = ((distances[4]! + distances[3]! + distances[2]! + distances[1]! + distances[0]!) / 5)
                    
                    //update display on different interval
                    if (totalTime.truncatingRemainder(dividingBy: calcInterval)  == 0) {
                        lastVelocity = ((oldestDistance - lastDistance) / timeInterval)
                        currentVelocity = ((lastDistance - currentDistance) / timeInterval)
                        currentAcceleration = ((lastVelocity - currentVelocity) / (2 * timeInterval))
                        
                        print(String(format: "TotalTime: %.4f seconds\n", totalTime))
                        print(String(format: "OldestDistance: %.4f meters", oldestDistance))
                        print(String(format: "LastDistance: %.4f meters", lastDistance))
                        print(String(format: "CurrentDistance: %.4f meters", currentDistance))
                        print(String(format: "LastVelocity: %.4f meters", lastVelocity))
                        print(String(format: "CurrentVelocity: %.4f meters", currentVelocity))
                        print(String(format: "CurrentAcceleration: %.4f meters\n", currentAcceleration))
                        
                        statusLabel?.text = String(format: "Acceleration: %.2f meters", currentAcceleration)
                        statusLabel?.textColor = statusColor
                        
                        if (lastDistance > currentDistance || oldestDistance > currentDistance) {
                            if (currentAcceleration > 1) {
                                statusColor = UIColor.red
                                AudioServicesPlayAlertSound(SystemSoundID(1304))
                                statusLabel?.textColor = statusColor
                            }
                            else{
                                statusColor = UIColor.white
                            }
                        }
                        else{
                            statusColor = UIColor.white
                        }
                        
                    }
                    else if (totalTime > 0.2) {
                        lastVelocity = currentVelocity
                        currentVelocity = ((lastDistance - currentDistance) / timeInterval)
                    }
                    
                }
                
                
                
                
            }
            
            
//            if distance < 1 {
//                statusLabel?.textColor = UIColor.red
//            }
//            else{
//                statusLabel?.textColor = UIColor.white
//            }
//            statusLabel?.text = String(format: "Distance: %.2f meters", distance)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                performSegue(withIdentifier: "settingsSegue", sender: self)
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
}
