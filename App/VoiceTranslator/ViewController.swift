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

struct Colors {
    static let primary=UIColor(red: 103/255.0, green: 80/255.0, blue: 164/255.0, alpha: 1.0)
    static let primaryContainer=UIColor(red: 234/255.0, green: 221/255.0, blue: 255/255.0, alpha: 1.0)
    static let onPrimary=UIColor.white
    static let onPrimaryContainer=UIColor(red: 23/255.0, green: 0/255.0, blue: 93/255.0, alpha: 1.0)
}

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
        startListen()
        audioManager.startSpeechToText(lanague: Lanague.EN.rawValue)
        DispatchQueue.main.asyncAfter(deadline: .now()+10.0, execute: {
            self.audioManager.stopRecording(success: true)
            self.audioManager.stopSpeechToText()
        })
        
        //play audio
    }
  
    
    // start listen function
    func startListen(){
        audioManager.recordingCompletion={[weak self] url,filesize in
            self?.handleRecordingCompletion(url: url, fileSize: filesize)
        }
        audioManager.startRecording()
    }
    
    // function to be executed after recording is finished
    func handleRecordingCompletion(url: URL?, fileSize: Double) {
        print("Recording completed. File size: \(fileSize) KB. URL: \(url?.path ?? "Unknown path")")
        print("Finaly the contexnt about the \(audioManager.speechText ?? "")")
    }
    
    
    // stop listen function22
    func stopListen(){
        audioManager.stopRecording(success: true)
        audioManager.stopSpeechToText()
    }
    
    //send user's audio and translated voice to server
    func sendSession(){
        
    }
    
    // start play the audio from server
    func playSpeaking(audioUrl:URL){
        audioManager.playingCompletion={[weak self] url,succed in
            self?.handlePlayingCompletion(url: url, succeed: succed)
        }
        audioManager.playBack(playUrl: audioUrl)
    }
    
    //function to be excuted after playing is finished
    func handlePlayingCompletion(url:URL?,succeed:Bool){
        print("Playing completed, File URL:\(url?.path ?? "Unknown path"),status:\(succeed)")
    }
    
    
    
    
}

