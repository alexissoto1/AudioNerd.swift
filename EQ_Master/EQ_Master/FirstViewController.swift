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
    
    var reverb : AVAudioUnitReverb! //Testing purposes
    
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
    private lazy var SliderToLabel : [UISlider: UILabel] = [Band1 : LabelB31, Band2 : LabelB62, Band3 : LabelB125, Band4 : LabelB250, Band5 : LabelB500, Band6 : LabelB1k, Band7 : LabelB2k, Band8 : LabelB4k, Band9 : LabelB8k, Band10 : LabelB16k]
    
    //Audio
    var AudiorRecorder: AudioRecorder!
    var timer: Timer!
    var filter_timer: Timer!
    private var volume = 0.0
    
    @IBOutlet var dBlabel : UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudiorRecorder = AudioRecorder()

        
        filter_timer = Timer.scheduledTimer(timeInterval: 1/30, target: self, selector: #selector(self.updateGain), userInfo: nil, repeats: true)
        
        //Audio engine testing purposes
        self.audioEngine.attach(self.reverb)
        reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.largeHall)
        reverb.wetDryMix = 100
        //Up to here
        
        self.audioEngine = AVAudioEngine.init()
        self.audioPlayerNode = AVAudioPlayerNode.init()
        self.audioUnitEQ = AVAudioUnitEQ(numberOfBands: 10)
        self.audioEngine.attach(self.audioPlayerNode)
        self.audioEngine.attach(self.audioUnitEQ)

        
        for i in 0...9 {
            let PASS = self.value(forKey: String(format: "Band%d", i+1)) as! UISlider
            PASS.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2)) //vertical position
            PASS.thumbTintColor = UIColor.red
        }
    }
    
    func setupEQ() { //Figure out where to implement this set up line!
        
        for i in 0...9 {

            let PASS_2 = self.value(forKey: String(format: "Band%d", i+1)) as! UISlider
            self.audioUnitEQ.bands[i].filterType =  .parametric
            self.audioUnitEQ.bands[i].frequency = frequencies[i]
            self.audioUnitEQ.bands[i].bandwidth = 0.5 // The smaller the bandwith, the higher the Q factor.
            self.audioUnitEQ.bands[i].gain = PASS_2.value
            self.audioUnitEQ.bands[i].bypass = false
        }
        
        self.audioPlayerNode.scheduleSegment(self.audioFile, startingFrame: 0, frameCount: AVAudioFrameCount(self.audioFile.length), at: nil, completionHandler: self.completed) //Change button when pressed.
        
        self.audioEngine.connect(self.audioPlayerNode, to: audioUnitEQ, format: self.audioFile.processingFormat)
        self.audioEngine.connect(audioUnitEQ, to: self.audioEngine.mainMixerNode, format: self.audioFile.processingFormat)
        
        let SR = 44100.0
        let format = self.audioEngine.mainMixerNode.outputFormat(forBus: 0)
        self.audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(SR), format: format, block:{ (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
        })
        
        start()
    }
    
    @objc func updateMeter() {
        DispatchQueue.main.async {
            self.dBlabel.text =  String(format: "%.2f dB", self.AudiorRecorder.volume)
        }
    }
    
    @objc func updateGain() {
        
        for i in 0...9 {
        
            let PASS_2 = self.value(forKey: String(format: "Band%d", i+1)) as! UISlider
            self.audioUnitEQ.bands[i].gain = PASS_2.value
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
            stopRec()
        }
    }
    
    @IBAction func restart (_ sender: Any){
        for i in 0...9{
            let band_restart = self.value(forKey: String(format: "Band%d", i+1)) as! UISlider
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
            setupEQ()
            self.audioPlay()
            sender.setTitle("Stop", for: .normal)
        } else {
            self.audioStop()
            sender.setTitle("Play", for: .normal)
        }
    }
    
    func record(){
        AudiorRecorder.record()
        timer = Timer.scheduledTimer(timeInterval: 1/30, target: self, selector: #selector(self.updateMeter), userInfo: nil, repeats: true)
        print("Recording...")
    }
    
    func stopRec(){
        AudiorRecorder.stop()
        self.audioFile = try! AVAudioFile(forReading: URL(fileURLWithPath: AudiorRecorder.fileURL.deletingPathExtension().path+".wav")) //Concise refference
    }
    
    func audioPlay() { //Build this whole thing in a separate class file.
        self.isPlaying = true
        
        self.audioPlayerNode.scheduleSegment(self.audioFile, startingFrame: 0, frameCount: AVAudioFrameCount(self.audioFile.length), at: nil, completionHandler: self.completed)
        
        self.audioPlayerNode.play()
    }

    
    func start(){
        if audioEngine.isRunning {
            return
        }
        do {
            try audioEngine.start()
        }catch{
            print("Could not start the Audio Engine")
        }
    }
    
    func completed() {
        if isPlaying {
            print("Completed")
            self.audioPlay()
        }
    }
    
    func audioStop() {
        self.isPlaying = false
        self.audioPlayerNode.stop()
        self.audioEngine.stop()
        self.audioEngine.mainMixerNode.removeTap(onBus: 0)
    }
}
