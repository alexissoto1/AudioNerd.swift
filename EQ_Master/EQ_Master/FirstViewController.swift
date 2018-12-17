//
//  FirstViewController.swift
//  EQ_Master
//
//  Created by Alexis Soto on 12/13/18.
//  Copyright © 2018 Alexis Soto. All rights reserved.
//

//Graphic EQ, 10 bands.

import UIKit
import MediaPlayer
import AVFoundation

class FirstViewController: UIViewController {
    
    //General Stuff
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    var audioUnitEQ = AVAudioUnitEQ(numberOfBands: 10)
    var isPlaying = false
    
    //EQ main buttons
    @IBOutlet var bypassSwitch : UISwitch!
    @IBOutlet var gainSlider : UISlider!
    
    //Audio outlets
    @IBOutlet var recSwitch : UISwitch!
    @IBOutlet var playStop : UIButton!
    @IBOutlet var restartButton : UIButton!
    @IBOutlet var gainLabel : UILabel!
    
    //band Frequencies
    let frequencies: [Float] = [31.25, 62.5, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]

    //All sliders
    @IBOutlet var Band1 : UISlider!
    @IBOutlet var Band2 : UISlider!
    @IBOutlet var Band3 : UISlider!
    @IBOutlet var Band4 : UISlider!
    @IBOutlet var Band5 : UISlider!
    @IBOutlet var Band6 : UISlider!
    @IBOutlet var Band7 : UISlider!
    @IBOutlet var Band8 : UISlider!
    @IBOutlet var Band9 : UISlider!
    @IBOutlet var Band10 : UISlider!
    
    //Metering levels
    @IBOutlet var LabelB31 : UILabel!
    @IBOutlet var LabelB62 : UILabel!
    @IBOutlet var LabelB125 : UILabel!
    @IBOutlet var LabelB250 : UILabel!
    @IBOutlet var LabelB500 : UILabel!
    @IBOutlet var LabelB1k : UILabel!
    @IBOutlet var LabelB2k : UILabel!
    @IBOutlet var LabelB4k : UILabel!
    @IBOutlet var LabelB8k : UILabel!
    @IBOutlet var LabelB16k : UILabel!
    
    //Slider to Label
    lazy var SliderToLabel : [UISlider: UILabel] = [Band1 : LabelB31, Band2 : LabelB62, Band3 : LabelB125, Band4 : LabelB250, Band5 : LabelB500, Band6 : LabelB1k, Band7 : LabelB2k, Band8 : LabelB4k, Band9 : LabelB8k, Band10 : LabelB16k]
    
    //Audio
    var AudiorRecorder: AudioRecorder!
    var timer: Timer!
    var volume = 0.0

    var Player = AVAudioPlayer()
    var audioPlayer: AudioPlayer!
    
    
    @IBOutlet var dBlabel : UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudiorRecorder = AudioRecorder()
        audioPlayer = AudioPlayer()
        
        self.audioEngine = AVAudioEngine.init()
        self.audioPlayerNode = AVAudioPlayerNode.init()
        self.audioUnitEQ = AVAudioUnitEQ(numberOfBands: 10)
        self.audioEngine.attach(self.audioPlayerNode)
        self.audioEngine.attach(self.audioUnitEQ)
        
        for i in 1...10 {
            let PASS = self.value(forKey: String(format: "Band%d", i)) as! UISlider
            PASS.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2)) //vertical position
            PASS.thumbTintColor = UIColor.red
            //PASS.thu
        }
    }
    
    func setupEQ() { //Figure out where to implement this set up line!
        
        for i in 1...10 {

            let PASS_2 = self.value(forKey: String(format: "Band%d", i)) as! UISlider
            self.audioUnitEQ.bands[i].filterType =  .parametric
            self.audioUnitEQ.bands[i].frequency = frequencies[i]
            self.audioUnitEQ.bands[i].bandwidth = 0.5 // The smaller the bandwith, the higher the Q factor.
            self.audioUnitEQ.bands[i].gain = PASS_2.value
            self.audioUnitEQ.bands[i].gain = PASS_2.value
            self.audioUnitEQ.bands[i].bypass = false
        }
        audioUnitEQ.bypass = bypassSwitch.isOn 
    }
    
    @objc func updateMeter() {
        DispatchQueue.main.async {
            self.dBlabel.text =  String(format: "%.2f dB", self.AudiorRecorder.volume)
        }
    }

    @IBAction func bypass (_ sender: UISwitch){
        if sender.isOn {
        audioUnitEQ.bypass = true
        }else{
        audioUnitEQ.bypass = false
        }
    }
    
    @IBAction func gain (_ sender: UISlider){
        audioUnitEQ.globalGain = sender.value
        gainLabel.text = String(format: "%.1f dB", sender.value)
        
    }
    
    @IBAction func bandGain (_ sender: UISlider){
        let val : Float = sender.value
        if let Label = SliderToLabel[sender]{
            Label.text = String(format: "%.1f dB", val)
        }
        
    }
    
    @IBAction func REC(_ sender: UISwitch){
        if sender.isOn == true {
            record()
        }else{
            stopRec() //From here these are the problematic lines of code. Saving the info nowhere!
        }
    }
    
    @IBAction func restart (_ sender: Any){
        for i in 1...10{
            let band_restart = self.value(forKey: String(format: "Band%d", i)) as! UISlider
            band_restart.value = 0
            }
        
        for i in [LabelB31, LabelB62, LabelB125, LabelB250, LabelB500, LabelB1k, LabelB2k, LabelB4k, LabelB8k, LabelB16k]{
            i?.text = "0.0 dB"
        }
        
        gainSlider.value = 0.5
        gainLabel.text = "0.5 dB"
        
        }
    
        //Add everything else!
    //}
    
    @IBAction func play(_ sender: UIButton) {
        if (!isPlaying) {
            self.audioPlay()
            sender.setTitle("Stop", for: .normal)
            print("Playing...")
        } else {
            self.audioStop()
            sender.setTitle("Play", for: .normal)
            print("Stopped")
        }
    }
    
    
    func record(){
        AudiorRecorder.record()
        timer = Timer.scheduledTimer(timeInterval: 1/30, target: self, selector: #selector(self.updateMeter), userInfo: nil, repeats: true)
        print("Recording...")
    }
    
    func stopRec(){
        AudiorRecorder.stop()
        print(AudiorRecorder.fileURL.absoluteString)
        audioPlayer.setupSession()
        audioPlayer.setup(fileURL: AudiorRecorder.fileURL)
        //Failed to initialize AVAudioPlayer
    }
    
    
    func audioPlay() {
        self.isPlaying = true
        audioPlayer.play()
    }

    func completion() {
        if self.isPlaying {
            DispatchQueue.main.async {
                self.play(self.playStop)
            }
        }
    }
    
    func audioStop() {
        self.isPlaying = false
        audioPlayer.stop()
//        self.audioPlayerNode.stop()
//        self.audioEngine.stop()
//        self.audioEngine.mainMixerNode.removeTap(onBus: 0)
    }
}
