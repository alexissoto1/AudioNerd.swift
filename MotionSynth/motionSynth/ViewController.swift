//
//  ViewController.swift
//  motionSynth
//
//  Created by Nikhil Singh on 12/21/17. Edited by Alexis Soto.
//  Copyright © 2018 Berklee EP-P453. All rights reserved.
//

import UIKit
import CoreMotion
import CsoundiOS

class ViewController: UIViewController {

    @IBOutlet var roll: UILabel!
    @IBOutlet var pitch: UILabel!
    @IBOutlet var yaw: UILabel!
    @IBOutlet var OnOff: UISwitch!
    
    // Touches
    var touchIDs = [Int](repeating: 0, count: 10)
    var touchX = [Float](repeating: 0, count: 10)
    var touchY = [Float](repeating: 0, count: 10)
    var touchXPtr = [UnsafeMutablePointer<Float>?](repeating: nil, count: 10);
    var touchYPtr = [UnsafeMutablePointer<Float>?](repeating: nil, count: 10);
    var touchArray = [UITouch?](repeating: nil, count: 10)

    //Number of touches
    private var tCount = 0
    @IBOutlet var Numtouches: UILabel!
    
    //Instrument number
    var InsNumb = 0
    
    //color
    var hue = 0.0
    var timer:Timer!
    
    // Declarations
    let csound = CsoundObj()
    lazy var csoundMotion = CsoundMotion(csoundObj: csound) // Create CsoundMotion instance
    lazy var motionManager: CMMotionManager? = csoundMotion?.motionManager    // Get Csound's CMMotionManager instance
    
    lazy var accHandler: (CMAccelerometerData?, Error?) -> () = { accelerometerData, error in
        
        guard let accData = accelerometerData else { return } //CHeck if accelerometer existed. if not, do not proceed.
        
//////////////////////////////
        var hue = Double(accData.acceleration.x)
        hue -= floor(hue)
/////////////////////////////

        // Place outer bounds on the location of generated UIView objects
        var x = (CGFloat(accData.acceleration.x) * self.view.frame.size.width) + self.view.center.x
        var y = (CGFloat(accData.acceleration.y * -0.5) * self.view.frame.size.height) + self.view.center.y
        let size = CGFloat(accData.acceleration.z * 200) + 100
        
        if(x > self.view.frame.size.width - 50) {
            x = self.view.frame.size.width - 50
        }
        
        if(x < 100) {
            x = 100
        }
        
        if(y > self.view.frame.size.height - 100) {
            y = self.view.frame.size.height - 100
        }
        
        if(y < 50) {
            y = 50
        }
        
        // Transform the object by rotating it using accelerometer data
        let rotation = (x + y) - CGFloat.pi
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let csdPath = Bundle.main.path(forResource: "motionSynth", ofType: "csd")
        csound.play(csdPath)
        // Ensure our CMMotionManager instance is not nil, display error alert and return if it is
        guard let manager = motionManager else {
            let alert = UIAlertController(title: "Error", message: "Error setting up CsoundMotion.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateHue), userInfo: nil, repeats: true)
            return
        }
        
        // Enable Csound's use of CoreMotion data
        csoundMotion?.enableAccelerometer()
        csoundMotion?.enableGyroscope()
        csoundMotion?.enableAttitude()
        
        // Set update intervals and start "pull" format updates
        manager.accelerometerUpdateInterval = 0.01
        manager.gyroUpdateInterval = 0.1
        manager.deviceMotionUpdateInterval = 0.1
        manager.startAccelerometerUpdates()
        manager.startGyroUpdates()
        manager.startDeviceMotionUpdates()
        
        // Start accelerometer "push" updates to predefined closure
        manager.startAccelerometerUpdates(to: .main, withHandler: accHandler)
        
        // Start gyroscope "push" updates to closure
        manager.startGyroUpdates(to: .main, withHandler: { gyroscopeData, error in
            guard gyroscopeData != nil else { return }
        })
        
        // Start device motion "push" updates to closure
        manager.startDeviceMotionUpdates(to: .main, withHandler: { deviceMotionData, error in
            guard let motionData = deviceMotionData else { return }
            
            // Set the text of relevant labels to attitude data parameters
            self.roll.text = String(format: "%.3f", motionData.attitude.roll)
            self.pitch.text = String(format: "%.3f", motionData.attitude.pitch)
            self.yaw.text = String(format: "%.3f", motionData.attitude.yaw)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Switch function
    @IBAction func OnOfffunc (_ sender: UISwitch){
    if OnOff.isOn == true{
        InsNumb = 2
        csound.sendScore("i-1 0 1")
    }else{
        InsNumb = 1
        csound.sendScore("i-2 0 1")
        }
    }
    
    @objc func updateHue() {
        guard let accData = motionManager?.accelerometerData else { return }
        hue = accData.acceleration.x
        print(hue)
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // For each touch in the touches set
        for touch in touches {
            let touchID = getTouchIDAssignment()
            if touchID != -1 {
                touchArray[touchID] = touch
                touchIDs[touchID] = 1
                
                // Create a CGPoint that describes the touch location
                let pt = touch.location(in: view)
                touchX[touchID] = Float(pt.x/view.frame.size.width) //Getting touch location.Default in viewCOntroller
                touchY[touchID] = Float(1 - (pt.y/view.frame.size.height)) // flip y value so zero is on
                
                touchXPtr[touchID]?.pointee = touchX[touchID]
                touchYPtr[touchID]?.pointee = touchY[touchID]
                
                //-2 will work in this case for instrument play lenght.
                csound.sendScore(String(format: "i1 0 -2", InsNumb))
                self.view.backgroundColor = UIColor(hue: CGFloat(hue), saturation: 1, brightness: 1, alpha: 1)
                //view.backgroundColor = UIColor.red
                tCount += touches.count
                Numtouches.text = String(format: "Touches: %d", tCount)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchID = getTouchID(touch)
            if touchID != -1 {
                touchIDs[touchID] = 0
                touchArray[touchID] = nil
                csound.sendScore(String(format: "i-1 0 1", InsNumb))
                self.view.backgroundColor = UIColor.white
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchID = getTouchID(touch)
            if touchID != -1 {
                touchIDs[touchID] = 0
                touchArray[touchID] = nil
                csound.sendScore(String(format: "i-1 0 1", InsNumb))
            }
        }
    }
    
    // Assigning touch ID numbers
    func getTouchIDAssignment() -> Int {
        for i in 0..<10 {
            if touchIDs[i] == 0 {
                return i
            }
        }
        return -1
    }
    
    // Get touch IDs
    func getTouchID(_ touch: UITouch) -> Int {
        for i in 0..<10 {
            if touchArray[i] == touch {
                return i
            }
        }
        return -1
    }
}
