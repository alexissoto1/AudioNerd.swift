//
//  SecondViewController.swift
//  EQ_Master
//
//  Created by Alexis Soto on 12/13/18.
//  Copyright © 2018 Alexis Soto. All rights reserved.
//

//Parametric EQ, FFT inclussion

import UIKit
import AVFoundation

class SecondViewController: UIViewController {
    
    //Outlets
    @IBOutlet var fftScreen : UIView!
    @IBOutlet var RecordSwitch : UISwitch!
    @IBOutlet var playStop : UIButton!
    @IBOutlet var BypassSwitch : UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

