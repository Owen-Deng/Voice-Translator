//
//  ViewController.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//
// three animation for ui, listenning:button, progress,
// func intro

// staus for ui and animation
//- listening/ both side  ,start listen, the otherside can not interact, listen animation, progress bar,
//- uplistenning , both can interact,


import UIKit

class ViewController: UIViewController {

    //status enum
    var currentStatus:UIStatus = .unListening{
        didSet{
            updateUIAnimation()
        }
    }
    
    //audiorecorder
    let audioManager=AudioManager() //
    
    enum UIStatus {
        case listening
        case unListening
        case speaking
        case loading
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //call the functiontest
        functionTest()
    }
    
    func updateUIAnimation(){
        switch currentStatus {
        case .listening:
            print("listening animation")
        case .unListening:
            print("unlistenning animation")
        case .speaking:
            print("speak animation")
        case .loading:
            print("load animation")
        }
    }
    
    
    // devloping for functionallity test 
    func functionTest(){
        //set closure for test
        audioManager.recordingCompletion={[weak self] url,filesize in
            self?.handleRecordingCompletion(url: url, fileSize: filesize)
        }
        //start record
        audioManager.startRecording()
        //10s stop
        DispatchQueue.main.asyncAfter(deadline: .now()+10.0, execute: {
            self.audioManager.stopRecording(success: true)
            
        })
        //play audio
    }
    
    
    // function to be executed after recording is finished
    func handleRecordingCompletion(url: URL?, fileSize: Double) {
        // Perform actions with the recording URL and file size
        print("Recording completed. File size: \(fileSize) KB. URL: \(url?.path ?? "Unknown path")")
    }
    
    
    // start listen function
    func startListen(){
        audioManager.recordingCompletion={[weak self] url,filesize in
            self?.handleRecordingCompletion(url: url, fileSize: filesize)
        }
        audioManager.startRecording()
    }
    
    
    
    // stop listen function22
    func stopListen(){
        audioManager.stopRecording(success: true)
    }
    
    //send user's audio and translated voice to server
    func sendSession(){
        
    }
    
    // start play the audio from server
    func playSpeaking(){
        
    }
    
    //
    
    
    
    
}

