//
//  ViewController.swift
//  SpeechRecognitionTest
//
//  Created by Evgheny on 15.05.17.
//  Copyright © 2017 Eugheny_Levin. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var textView: LETextView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest:SFSpeechAudioBufferRecognitionRequest? //This object handles the speech recognition requests. It provides an audio input to the speech recognizer
    private var recognitionTask: SFSpeechRecognitionTask? //The recognition task where it gives you the result of the recognition request
    private let audioEngine = AVAudioEngine () //This is your audio engine. It is responsible for providing your audio input.
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        micButton.isEnabled = false
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization{(autStatus) in
        
            var isButEnabled = false
        
            switch autStatus{
                
            case .authorized: isButEnabled = true
            case .denied:isButEnabled = false
                 print("denied")
            case .restricted: isButEnabled = false
                print("restricted")
            case .notDetermined: isButEnabled = false
                print("notDetermined")
            }
            
            OperationQueue.main.addOperation {
                self.micButton.isEnabled = isButEnabled
            }
            
        }
    
    }
    
    func startRecord() -> Void {
        
    
        activityIndicator.startAnimating()
        
        if recognitionTask != nil{
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch{
            print("Error in setting properties")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine error")
        }
        
        guard let recognitionRequest = recognitionRequest  else {
            fatalError("Unable to create recognitionRequest")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
        
        var isFinal = false
            
            if result != nil{
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal{
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.micButton.isEnabled = true
            }
        
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {(buffer, when) in
        
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch  {
            print("Audio Engine start Error")
        }
            
        textView.text = "Say something!"
        
    }

    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available {
            micButton.isEnabled = true;
        } else {
            micButton.isEnabled = false
        }
        
    }
    
    
    @IBAction func onMicTapped(_ sender: Any) {
        
        if audioEngine.isRunning{
            audioEngine.stop()
            recognitionRequest?.endAudio()
            micButton.isEnabled = false
            self.activityIndicator.stopAnimating()
            
        } else{
            startRecord()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

