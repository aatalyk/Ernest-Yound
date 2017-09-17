//
//  MySpeechRecognizer.swift
//  Contactis_Challenge
//
//  Created by ARKALYK AKASH on 7/29/17.
//  Copyright © 2017 ARKALYK AKASH. All rights reserved.
//
import Foundation
import Speech

class MySpeechRecognizer{
    //MARK: - Properties
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: .current)
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    //MARK: - Initializers
    private init () { }
    
    static let shared = MySpeechRecognizer()
    
    //MARK: - Methods
    func startRecordingWith(closure: @escaping (String?) -> Void){
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                isFinal = (result?.isFinal)!
                if isFinal {
                    var resultString = (result?.bestTranscription.formattedString)!.lowercased()
                    resultString = resultString.replacingOccurrences(of: "one", with: "1") //Work around a weird behavior
                    closure(resultString)
                }
            }else{
                closure(nil)
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
}
