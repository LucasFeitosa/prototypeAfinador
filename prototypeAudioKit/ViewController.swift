//
//  ViewController.swift
//  prototypeAudioKit
//
//  Created by Lucas Feitosa on 27/01/19.
//  Copyright © 2019 Lucas. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController {

    @IBOutlet weak var audioInputPlot: EZAudioPlot!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var noteNamesWithFlatsLabel: UILabel!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    let noteFrequencies = [329.63, 246.94, 196.0, 146.83, 110.0, 82.407]
    
    
    func setupPlot(){
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        // Do any additional setup after loading the view, typically from a nib.
        
        //testPerformance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        
        do{
            try AudioKit.start()
        }catch{
            AKLog("Audiokit did not start")
        }
        
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
    }
    
    @objc func updateUI(){
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            
            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]){
                frequency /= 2.0
            }
            
            while frequency < Float(noteFrequencies[0]){
                frequency *= 2.0
            }
            
            var minDistance: Float = 10_000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count{
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance{
                    index = i
                    minDistance = distance
                }
            }
            
            
            noteNamesWithFlatsLabel.text = frequencyToNotes(frequency: Float(tracker.frequency))
        }
        
    }
    func frequencyToNotes(frequency: Float) -> String{
        var note: String = "Out of range"
        print(frequency)
        switch frequency{
        case 328.0 ..< 329.63:
            note = "E"
            print(note)
        case 245.0 ..< 246.94:
            note = "B"
        case 195.0 ..< 196.0:
            note = "G"
        case 145.0 ..< 146.83:
            note = "D"
        case 109.0 ..< 110.0:
            note = "L"
        case 82.0 ..< 82.407:
            note = "E"
        default:
            print("searching")
        }
        
        return note
    }
    
    
}

