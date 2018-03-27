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

class ViewController: UIViewController, ARSCNViewDelegate {

    var statusLabel:UILabel?
    var pointerLabel:UILabel?
    
    //values for calculating acceleration
    var oldestDistance:CGFloat = 0.0
    var lastDistance:CGFloat = 0.0
    var currentDistance:CGFloat = 0.0
    
    var lastVelocity:CGFloat = 0.0
    var currentVelocity:CGFloat = 0.0
    
    var currentAcceleration:CGFloat = 0.0
    
    var totalTime:CGFloat = 0.0
    var timeInterval:CGFloat = 0.1
    

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        statusLabel = UILabel(frame: CGRect.zero)
        statusLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        statusLabel?.textAlignment = .center
        statusLabel?.textColor = .white
        statusLabel?.frame = CGRect(x: 0, y: 16, width: view.bounds.width, height: 64)
        
        // Show the X in the middle of the screen so the user knows what the distance is calculated for
        pointerLabel = UILabel(frame: CGRect.zero)
        pointerLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        pointerLabel?.textAlignment = .center
        pointerLabel?.textColor = .white
        pointerLabel?.center = sceneView.center
        pointerLabel?.text = "X"
        
        sceneView.addSubview(pointerLabel!)
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneView.addSubview(statusLabel!)
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        Timer.scheduledTimer(timeInterval: TimeInterval(self.timeInterval), target: self, selector: #selector(ViewController.distanceHandler), userInfo: nil, repeats: true)
//        tapRecognizer.numberOfTapsRequired = 1
//        sceneView.addGestureRecognizer(tapRecognizer)
        // Set the scene to the view
//        sceneView.scene = scene
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
        totalTime += timeInterval   //update the total time
        let tapLocation = view.center
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let result = hitTestResults.first {
            let distance = result.distance
            
            //update distances
            oldestDistance = lastDistance
            lastDistance = currentDistance
            currentDistance = distance
            
            //will break if doing math with 0s
            if (totalTime > 0.3) {
                lastVelocity = ((oldestDistance - lastDistance) / timeInterval)
                currentVelocity = ((lastDistance - currentDistance) / timeInterval)
                currentAcceleration = ((lastVelocity - currentVelocity) / (2 * timeInterval))
                
                statusLabel?.text = String(format: "Distance: %.2f meters", currentAcceleration)
            }
            else if (totalTime > 0.2) {
                lastVelocity = currentVelocity
                currentVelocity = ((lastDistance - currentDistance) / timeInterval)
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
}
