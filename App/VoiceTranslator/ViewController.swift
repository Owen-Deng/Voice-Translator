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
    static let primary=UIColor(red: 103/255.0, green: 80/255.0, blue: 164/255.0, alpha: 1.0) //6750A4
    static let primaryContainer=UIColor(red: 234/255.0, green: 221/255.0, blue: 255/255.0, alpha: 1.0) //EADDFF
    static let onPrimary=UIColor.white //fffff
    static let onPrimaryContainer=UIColor(red: 23/255.0, green: 0/255.0, blue: 93/255.0, alpha: 1.0) //21005D
}



class ViewController: UIViewController ,SpeakButtonViewDelegate {
   
    // set active
    //delegae function when touch the button
    func buttonViewTapped(_ speakButtonView: SpeakButtonView) {
        if activeStatus == .noActive{
            startListen(button: speakButtonView)
        }else if(speakButtonView.status == .recording){
            stopListen(button: speakButtonView)
        }
    }
    
    var activeStatus:ActiveStatus = .noActive
    enum ActiveStatus{
        case myActive
        case yourActive
        case noActive
    }
    
    //audiorecorder
    let audioManager=AudioManager() //
    
    // the value of two people who are speaking
    var myLanguage="English"{
        didSet{myLabel.text=myLanguage}
    }
    var yourLanguage="Mandarin"{
        didSet{yourLabel.text=yourLanguage}
    }
    
    func getLanguageiOSStr(_ lan:String) -> String{
        if let index = LANGUAGENAMES.firstIndex(of: lan) {
            return LANGUAGEIOS[index]
        }
        return ""
    }
    
    //UI properties
    @IBOutlet weak var myButtonView: SpeakButtonView!
    
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var yourButtonView: SpeakButtonView!
    
    @IBOutlet weak var yourLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVC()
    }
    
    //view controller setup function
    func setupVC(){
        myButtonView.delegate=self
        yourButtonView.delegate=self
    }
    
    
    // devloping for functionallity test 
    func functionTest(){
      //  startListen()
        audioManager.startSpeechToText(lanague: LANGUAGEIOS[0])
        DispatchQueue.main.asyncAfter(deadline: .now()+10.0, execute: {
            self.audioManager.stopRecording(success: true)
            self.audioManager.stopSpeechToText()
        })
        
        //play audio
    }
    
    func switchLanague(){
        let temp=myLanguage
        myLanguage=yourLanguage
        yourLanguage=temp
    }
  
    //set active
    // start listen function both recording and speechto text
    func startListen( button: SpeakButtonView){
        var listenLang="English"
        if activeStatus == .noActive{
            if button == myButtonView {
                activeStatus = .myActive
                print("myButtonView activate")
                listenLang=getLanguageiOSStr(myLanguage)
            }else{
                activeStatus = .yourActive
                print("yourButtonView activate")
                listenLang=getLanguageiOSStr(yourLanguage)
            }
            audioManager.recordingCompletion={[weak self] url,filesize in
                self?.handleRecordingCompletion(url: url, fileSize: filesize)
            }
            audioManager.startRecording()
            audioManager.startSpeechToText(lanague: listenLang)
            button.status = .recording
        }
    }
    
    
    // function to be executed after recording is finished
    func handleRecordingCompletion(url: URL?, fileSize: Double) {
        print("Recording completed. File size: \(fileSize) KB. URL: \(url?.path ?? "Unknown path")")
        print("Finaly the contexnt about the \(audioManager.speechText ?? "")")
        if activeStatus == .myActive{
            myButtonView.status = .loading
        }else{
            yourButtonView.status = .loading
        }
        sendSession() // after recoding then send
    }
    
    
    // stop listen function22
    func stopListen(button:SpeakButtonView){
        if button.status == .recording{
            audioManager.stopRecording(success: true)
            audioManager.stopSpeechToText()
            button.status = .loading // turn the recording to loading
        }
    }
    
    //send user's audio and translated voice to server
    func sendSession(){
//        NSLog("StartSendData", )
    }
    
    // start play the audio from server
    func playSpeaking(audioUrl:URL){
        if activeStatus == .myActive{
            myButtonView.status = .playing
        }else{
            yourButtonView.status = .playing
        }
        audioManager.playingCompletion={[weak self] url,succed in
            self?.handlePlayingCompletion(url: url, succeed: succed)
        }
        audioManager.playBack(playUrl: audioUrl)
    }
    
    // set active
    //function to be excuted after playing is finished
    func handlePlayingCompletion(url:URL?,succeed:Bool){
        print("Playing completed, File URL:\(url?.path ?? "Unknown path"),status:\(succeed)")
        if activeStatus == .myActive{
            myButtonView.status = .normal
        }else{
            yourButtonView.status = .normal
        }
        activeStatus = .noActive
    }
    
    
    
    
}

