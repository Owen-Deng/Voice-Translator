//
//  AudioRecorder.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation
import AVFoundation
import Speech



let LANGUAGENAMES:[String]=["English","Mandarin"]
let LANGUAGEIOS:[String]=["en-US","zh-CN"]
let LANGUAGESEVER:[String]=["en","zh"]



class AudioManager: NSObject, AVAudioRecorderDelegate,AVAudioPlayerDelegate {

    var audioRecorder: AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var recordingURL: URL?
    var recordingCompletion: ((URL?, Double) -> Void)?  // using for callback function
    var playingCompletion:((URL?,Bool) -> Void)? //using for callback function
    var audioSession:AVAudioSession!

    var speechRecognizer:SFSpeechRecognizer?
    var recognitionRequest:SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask:SFSpeechRecognitionTask?
    var speechText:String?
    let audioEngine = AVAudioEngine() //must init before session out of the function
 
    var buttonView:SpeakButtonView?
    var audioPower:Float=0.0
    
    override init() {
        super.init()
        setupSpeechRecognition()
    }
    
    // set up the speech recognition
    func setupSpeechRecognition(){
        speechRecognizer=SFSpeechRecognizer()
        SFSpeechRecognizer.requestAuthorization{authStatus in
            if authStatus == .authorized {
                print("Speech recgonition is authorized ")
            }else{
                print("Speech recgonition is not authorized")
            }
        }
    }
    
    //start speechto text
    func startSpeechToText(lanague:String){
        speechRecognizer=SFSpeechRecognizer(locale: Locale(identifier: lanague)) 
        
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
                    print("Speech recognition is not available.")
                    return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
                    print("Recognition request is nil.")
            return
        }

        do {
                    // Set up audio session for speech recognition
            let session=AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default, options: [])
            try session.setActive(true,options: .notifyOthersOnDeactivation)

                    // Set up recognition task
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
                if let result = result {
                            // Extract the recognized text from the result
                    let recognizedText = result.bestTranscription.formattedString
                
                   // print("Recognized Text: \(recognizedText)")
                    audioRecorder!.updateMeters()
                    audioPower=audioRecorder?.peakPower(forChannel: 0) ?? 0.0
                    print("audioPower: \(audioPower)")
                    self.speechText=recognizedText
                } else if let error = error {
                    print("Speech recognition error: \(error.localizedDescription)")
                }
            }

                    // Start the audio engine
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: audioEngine.inputNode.outputFormat(forBus: 0)) {
                (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            audioEngine.prepare()
            do{
                try audioEngine.start()
            }
            catch {
                fatalError("Audio engine could not start")
            }

        } catch {
                print("Error setting up speech recognition: \(error.localizedDescription)")
        }
    }
    
    // Function to stop speech-to-text recognition
    func stopSpeechToText() {
        audioRecorder?.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    

 

    func startRecording() {
        // Set up audio session
        audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .default, options: []) // if modecategory is playandRecord the volume will be low
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup error: \(error.localizedDescription)")
        }

        // Set up file name and path for the recording
        let fileName = "myAudioFile.wav" // You can use any desired file name and format
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsDirectory.appendingPathComponent(fileName)

        // Set up audio recorder settings
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // Create audio recorder
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: audioSettings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            stopRecording(success: false)
            print("Audio recorder setup error: \(error.localizedDescription)")
        }
        
        // start record
        if let audioRecorder = audioRecorder, !audioRecorder.isRecording {
            audioRecorder.record()
            print("Start Recording url\(audioRecorder.url)")
        }
    }

    
    func stopRecording(success:Bool){
        if let audioRecorder=audioRecorder, audioRecorder.isRecording{
            audioRecorder.stop()
        }
        if success{
            print("StopRecording success saving into file")
        }else{
            print("StopRecording fail")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    
    func playBack(playUrl:URL?){
        if let playingURl=playUrl{
            do {
                let session=AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [])
                try session.setActive(true)
                audioPlayer=try AVAudioPlayer(contentsOf: playingURl)
                audioPlayer?.delegate=self
                audioPlayer?.volume=1.0
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                print("Start playing: \(playingURl)")
            }catch{
                print("Playing error \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            if let fileSize = getFileSize(url: recordingURL) {
                recordingCompletion?(recordingURL, fileSize)
            }
        } else {
            print("Recording failed.")
            recordingCompletion?(nil, 0.0)
        }
        
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag{
            print("Play finished succeed")
            playingCompletion?(recordingURL,flag)
        }else{
            print("Play finished unsucceed")
            playingCompletion?(recordingURL,flag)
        }
    }

    func getFileSize(url: URL?) -> Double? {
        guard let url = url else { return nil }

        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[FileAttributeKey.size] as? Double {
                // Convert to kilobytes
                return fileSize / (1024.0)
            }
        } catch {
            print("Error getting file size: \(error.localizedDescription)")
        }

        return nil
    }

    func getCompletedRecording() -> URL? {
        return recordingURL
    }
}

