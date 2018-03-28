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

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    let pickerData = ["Mozzarella","Gorgonzola","Provolone","Brie","Maytag Blue","Sharp Cheddar","Monterrey Jack","Stilton","Gouda","Goat Cheese", "Asiago"]

    
    @IBOutlet weak var alarmPicker: UIPickerView!
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var decelerationThresholdLabel: UILabel!
    
    @IBOutlet weak var soundPicker: UIPickerView!
    
    var value = 1.0
    var alarmValue = "Mozzarella"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmPicker.dataSource = self
        alarmPicker.delegate = self
        let defaults = UserDefaults.standard
        if let thresholdValue = defaults.string(forKey: "threshold") {
            decelerationThresholdLabel.text = thresholdValue
            value = Double(thresholdValue)!
            stepper.minimumValue = 1
            stepper.value = value
            stepper.maximumValue = 100
        }
        if let alarmValueStored = defaults.string(forKey: "alarm") {
            alarmPicker.selectRow(pickerData.index(of: alarmValueStored)!, inComponent: 0, animated: true)
        }
        // Do any additional setup after loading the view.
    }

    
    
    
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        decelerationThresholdLabel.text = String("\(sender.value)")
    }
    //sign the user out of firebase and send them back to the login screen when the "logout" button is pressed
    @IBAction func didTapLogout(_ sender: Any) {
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! UINavigationController
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(decelerationThresholdLabel.text, forKey: "threshold")
        defaults.set(alarmValue, forKey: "alarm")
        performSegue(withIdentifier: "mainViewSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        alarmValue = pickerData[row]
        return pickerData[row]
    }

}
