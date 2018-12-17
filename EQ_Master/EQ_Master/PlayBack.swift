//
//  PlaybackViewController.swift
//  PhonoCam
//
//  Created by Alexis Soto on 12/14/18.
//  Copyright © 2018 Alexis Soto. All rights reserved.
//

import UIKit

class PlaybackViewController: UIViewController {
    
    var audioPlayer:AudioPlayer!
    var filePath = ""
    
    class func create(filePath:String) -> PlaybackViewController { //Because of class func, just the class can acess it, not the instance!!!!
        let vc = UIStoryboard(name: "Playback", bundle: nil).instantiateViewController(withIdentifier: "playback") as! PlaybackViewController
        vc.filePath = filePath
        return vc
    }
    
    override func viewDidLoad() {
        let url = URL(fileURLWithPath: filePath)
        
        
        audioPlayer = AudioPlayer()
        audioPlayer.setup(fileURL: URL(fileURLWithPath: url.deletingPathExtension().path+".m4a"))
        audioPlayer.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioPlayer.stop()
    }
}
