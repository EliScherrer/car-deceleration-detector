//
//  SettingsViewController.swift
//  ARScene
//
//  Created by Eli Scherrer on 2/26/18.
//  Copyright © 2018 Samuel Carbone. All rights reserved.
//
// link to sounds list -> http://iphonedevwiki.net/index.php/AudioServices

import UIKit
import Firebase
import AVFoundation
import AudioToolbox

class SettingsViewController: UIViewController {

    @IBOutlet weak var decelerationThresholdLabel: UILabel!
    @IBOutlet weak var thresholdAdjuster: UIStepper!
    
    @IBOutlet weak var soundPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    
    
    
    //sign the user out of firebase and send them back to the login screen when the "logout" button is pressed
    @IBAction func didTapLogout(_ sender: Any) {
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! UINavigationController
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
