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
    var currentStatus:UIStatus = .unListening
    
    //audiorecorder
    let audioRecorder=AudioRecorder()
    
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
    
    //main config before when the viewcontroller didload
    func initConfig(){
        
    }
    
    // devloping for functionallity test 
    func functionTest(){
        //start record
        audioRecorder.startRecording()
        //10s stop
        DispatchQueue.main.asyncAfter(deadline: .now()+10.0, execute: {
            self.audioRecorder.stopRecording(success: true)
        })
        //play audio
    }
    
    
    
    // start listen function
    func startListen(){
        
    }
    
    // stop listen function22
    func stopListen(){
        
    }
    
    //send user's audio and translated voice to server
    func sendSession(){
        
    }
    
    // start play the audio from server
    func playSpeaking(){
        
    }
    
    //
    
    
    
    
}

