//
//  ThirdViewController.swift
//  navProcessor
//
//  Copyright © Alexis Soto. All rights reserved.
//

import UIKit
import CsoundiOS

class ThirdViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet var volSlider: UISlider!
    @IBOutlet var verbSlider: UISlider!
    @IBOutlet var distSlider: UISlider!
    
    @IBOutlet var kVolume: UILabel!
    
    @IBOutlet var levelSlider: UISlider!
    @IBOutlet var keyboard: CsoundVirtualKeyboard!
    
    // Declarations
    let csound = SharedInstances.csound
    var verbPtr: UnsafeMutablePointer<Float>? //Define pointer.
    var distPtr: UnsafeMutablePointer<Float>?
    var levlPtr: UnsafeMutablePointer<Float>?
    var VolPtr: UnsafeMutablePointer<Float>?
    var verb: Float = 0
    var dist: Float = 0
    var vol: Float = 0
    var vol1: Float = 0
    var csoundUI: CsoundUI!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        csoundUI = CsoundUI(csoundObj: csound)
        csound.addBinding(self)
    
        keyboard.keyboardDelegate =  self
        
        
        // The .forEach method allows us to quickly perform some process on elements of a collection (denoted by $0, generally)
        // Here we use it to quickly initialize our temp values to whatever the sliders are set to
        [volSlider, verbSlider, distSlider, levelSlider].forEach { anyValueChanged($0) } //$0 is just a place holder to get whatever comes.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Start corresponding instrument and stop the other instrument if it is running
        csound.sendScore("i1.1 0 -1")
    }
    
    @IBAction func anyValueChanged(_ sender: UISlider) {
        switch sender {
        case verbSlider: verb = sender.value
        case distSlider: dist = sender.value
        case volSlider: vol = sender.value
        case levelSlider: vol1 =  sender.value
        default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func levelChange(_ sender: UISlider) {
        // Mock level meter with minimum track color of slider
        let color = UIColor(hue: CGFloat(1/3 - (sender.value/3)), saturation: 1, brightness: 1, alpha: 1)
        sender.minimumTrackTintColor = color
        kVolume.text = String(format: "Keyboard Volume: %.2f", sender.value)
        
        
    }
}

// CsoundBinding methods
extension ThirdViewController: CsoundBinding { //CsoundBiding is in the framework.
    func setup(_ csoundObj: CsoundObj) {
        // Setup channel pointers for manual Csound binding
        verbPtr = csoundObj.getInputChannelPtr("verb", channelType: CSOUND_CONTROL_CHANNEL)
        distPtr = csoundObj.getInputChannelPtr("dist", channelType: CSOUND_CONTROL_CHANNEL)
        levlPtr = csoundObj.getInputChannelPtr("levl", channelType: CSOUND_CONTROL_CHANNEL)
        VolPtr = csoundObj.getInputChannelPtr("vol1", channelType: CSOUND_CONTROL_CHANNEL)
    }
    
    func updateValuesToCsound() {
        // Update values at channel pointer addresses
        verbPtr?.pointee = verb
        distPtr?.pointee = dist
        levlPtr?.pointee = vol
        VolPtr?.pointee = vol1
    }
}

// CsoundVirtualKeyboard methods
extension ThirdViewController: CsoundVirtualKeyboardDelegate {
    // KeyboardDelegate method called when the key is released
    func keyUp(_ keybd: CsoundVirtualKeyboard, keyNum: Int) {
        let score = String(format: "i-2.%003d 0 -1 %d 1", keyNum+60, keyNum+60)
        csound.sendScore(score)
    }
    
    // KeyboardDelegate method called when the key is pressed
    func keyDown(_ keybd: CsoundVirtualKeyboard, keyNum: Int) {
        let score = String(format: "i2.%003d 0 -1 %d 1", keyNum+60, keyNum+60)
        csound.sendScore(score)
    }
    
    // Set keyboard delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "keyboard" { //Looking for identifier that has "keyboard" on it.
            (segue.destination.view as? CsoundVirtualKeyboard)?.keyboardDelegate = self
        }
    }
}

