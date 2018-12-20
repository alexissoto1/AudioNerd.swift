//
//  AudioRecorder.swift
//  EQ_Master
//
//  Created by Alexis Soto on 12/14/18.
//  Copyright © 2018 Alexis Soto. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject {
    
    var recorder:AVAudioRecorder!
    var fileURL:URL!
    private var timer:Timer!
    var curTime = ""
    var volume = 0.0
    
    func setup(){
        setRecordingPath()
        
        let settings : [String: Any] = [
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 24000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        
        //Setup the recorder
        do {
            try recorder = AVAudioRecorder(url: fileURL.appendingPathExtension("wav"), settings: settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
        } catch {
            recorder = nil
            print("Failed to initialize AVAudioRecorder")
            print(error.localizedDescription)
        }
    }
    
    func setupSession(){
        let session = AVAudioSession.sharedInstance()
        
        do{
            try session.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
            print("Failed to initialize AVAudioSession")
            print(error.localizedDescription)
        }
        
        do{
            try session.setActive(true, options: [])
        } catch {
            print("Failed to activate AVAudioSession")
            print(error.localizedDescription)
        }
    }
    
    func record(){
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if(granted){
                DispatchQueue.main.async {
                    self.setupSession()
                    self.setup()
                    if(self.recorder != nil){
                        self.recorder.record()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                    }
                }
            } else {
                print("Not permission granted.")
            }
        }
    }
    
    func stop(){
        recorder?.stop()
        timer.invalidate()
    }
    
    func delete(){
        stop()
        recorder?.deleteRecording()
    }
    
    func setRecordingPath(){
        let filePaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] //.documetnDirectory is the place to save files on Apple devices.
        fileURL = filePaths.appendingPathComponent("AudioFile")
    }
    
    @objc func update(_ timer:Timer){
        if recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            curTime = String(format: "%02d:%02d", min, sec)
            recorder.updateMeters()
            volume = Double(recorder.averagePower(forChannel:0))
        }
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print(error!)
    }
}
