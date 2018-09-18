import UIKit
import CsoundiOS

class ViewController: UIViewController {
    
    @IBOutlet var freqSlider: UISlider! // Frequency slider
    @IBOutlet var genButton: UIButton!  // Button to send score message
    @IBOutlet var freqValue: UILabel!   // Frequency value label
    @IBOutlet var volSlider: UISlider! //Volume slider
    @IBOutlet var volValue: UILabel! //Volume value
    
    // Create CsoundUI instance
    let csound = CsoundObj()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray

        let csoundUI = CsoundUI(csoundObj: csound)
        csoundUI?.add(freqSlider, forChannelName: "freq")
        
        let csoundvolume = CsoundUI(csoundObj: csound)
        csoundvolume?.add(volSlider, forChannelName: "vol")
        
        let csdPath = Bundle.main.path(forResource: "SoundSource", ofType: "csd")
        csound.play(csdPath)
    }
    
    // Stop button pushed
    @IBAction func stopTone(_ sender: UIButton) {
        csound.sendScore("i99 0 0.2 1")
        csound.sendScore("i99 0 0.2 2")
        csound.sendScore("i99 0 0.2 3")
        csound.sendScore("i99 0 0.2 4")
    }
    
    // Square play button pushed
    @IBAction func startSquare(_ sender: UIButton) {
        csound.sendScore("i99 0 0.2 1")
        csound.sendScore("i99 0 0.2 3")
        csound.sendScore("i99 0 0.2 4")
        csound.sendScore("i2 0 10000")
    }
    
    // Sine play button pushed
    @IBAction func startSine(_ sender: UIButton) {
        csound.sendScore("i99 0 0.2 2")
        csound.sendScore("i99 0 0.2 3")
        csound.sendScore("i99 0 0.2 4")
        csound.sendScore("i1 0 10000")
    }
    
    // Pulse play button pushed
    @IBAction func startPulse(_ sender: UIButton) {
        csound.sendScore("i99 0 0.2 2")
        csound.sendScore("i99 0 0.2 1")
        csound.sendScore("i99 0 0.2 4")
        csound.sendScore("i3 0 10000")
    }
    
    //"Some" wave play button pushed
    @IBAction func startSome( sender: UIButton) {
        csound.sendScore("i99 0 0.2 2")
        csound.sendScore("i99 0 0.2 1")
        csound.sendScore("i99 0 0.2 3")
        csound.sendScore("i4 0 10000")
    }
    
    // Slider value changed
    @IBAction func changeFreq(_ sender: UISlider) {
        freqValue.text = String(format: "%.1f Hz", sender.value)
    }
    
    // Slider volume changed
    @IBAction func changevol(_ sender: UISlider) {
        volValue.text = String(format: "%.1f", sender.value)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

