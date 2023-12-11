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
import AVFAudio

struct Colors {
    static let primary=UIColor(red: 103/255.0, green: 80/255.0, blue: 164/255.0, alpha: 1.0) //6750A4
    static let primaryContainer=UIColor(red: 234/255.0, green: 221/255.0, blue: 255/255.0, alpha: 1.0) //EADDFF
    static let onPrimary=UIColor.white //fffff
    static let onPrimaryContainer=UIColor(red: 23/255.0, green: 0/255.0, blue: 93/255.0, alpha: 1.0) //21005D
}



class ViewController: UIViewController ,SpeakButtonViewDelegate, AVAudioPlayerDelegate {
   
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
        return "en-US" // default
    }
    
    func getLanguageServerStr(_ lan:String)->String{
        if let index = LANGUAGENAMES.firstIndex(of: lan) {
            return LANGUAGESEVER[index]
        }
        return "en" //default
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
        NSLog("Starting recording\(Date())")
        var listenLang="English" //default value
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
            DispatchQueue.main.async {
                self.audioManager.startRecording()
                self.audioManager.startSpeechToText(lanague: listenLang)
                self.audioManager.buttonView=button// for animation
                button.status = .recording
            }
        }
    }
    
    //MARK:  pending for send to server
    // function to be executed after recording is finished
    func handleRecordingCompletion(url: URL?, fileSize: Double) {
        print("Recording completed. File size: \(fileSize) KB. URL: \(url?.path ?? "Unknown path")")
        print("Finaly the contexnt:  \(audioManager.speechText ?? "")")
        if let speechText = audioManager.speechText{
            sendSession(speechText: speechText, audioFileUrl: url)
        }
      
    }
    
    
    // stop listen function22
    func stopListen(button:SpeakButtonView){
        if button.status == .recording{
            audioManager.stopRecording(success: true)
            audioManager.stopSpeechToText()
        }
    }
    
    //send user's audio and translated voice to server
    var connectManager=ConnectManager.shared
    func sendSession(speechText:String,audioFileUrl:URL?){
        NSLog("Start Send Data Time: \(Date())" )
        var srcLan="en"
        var tarLan="zh"
        if activeStatus == .myActive{
            srcLan=getLanguageServerStr(myLanguage)
            tarLan=getLanguageServerStr(yourLanguage)
            myButtonView.status = .loading
        }else if activeStatus == .yourActive{
            srcLan=getLanguageServerStr(yourLanguage)
            tarLan=getLanguageServerStr(myLanguage)
            yourButtonView.status = .loading
        }
        if let urlPath=audioFileUrl, speechText != "" {
            
            do {
                let audioData = try Data(contentsOf: urlPath )
                connectManager.sendAudioPostRequest(srcLan: srcLan, tarLan: tarLan, text: speechText, audioData: audioData){result in
                    switch result {
                    case .success(let data):
                       
               
                        NSLog("Success! Data received, Data: \(Date())")
                        guard let fileURL = self.saveDataToFile(data, withExtension: "wav") else {
                                 print("Error saving data to file")
                                 return
                        }
                        self.playSpeaking(audioUrl: fileURL)
                    case .failure(let error):
                        if self.activeStatus == .myActive{
                            self.myButtonView.status = .normal
                        }else if self.activeStatus == .yourActive{
                            self.yourButtonView.status = .normal
                        }
                        self.activeStatus = .noActive
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }catch {
                print(" not able to upload data\(error)")
            }
        }
    }
    
    
    private func saveDataToFile(_ data: Data, withExtension fileExtension: String) -> URL? {
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectoryURL.appendingPathComponent("tempAudioFile.\(fileExtension)")

            do {
                try data.write(to: tempFileURL)
                return tempFileURL
            } catch {
                print("Error saving data to file: \(error)")
                return nil
            }
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

