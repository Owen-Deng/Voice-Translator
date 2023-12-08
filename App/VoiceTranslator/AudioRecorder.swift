//
//  AudioRecorder.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate,AVAudioPlayerDelegate {

    var audioRecorder: AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var recordingURL: URL?
    var recordingCompletion: ((URL?, Double) -> Void)?
    var audioSession:AVAudioSession!

    override init() {
        super.init()
        setupAudioRecorder()
    }

    func setupAudioRecorder() {
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
            audioRecorder?.prepareToRecord()
        } catch {
            stopRecording(success: false)
            print("Audio recorder setup error: \(error.localizedDescription)")
        }
    }

    func startRecording() {
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
    }
    
    func playBack(){
        if let playingURl=recordingURL{
            do {
                audioPlayer=try AVAudioPlayer(contentsOf: playingURl)
                audioPlayer?.delegate=self
                audioPlayer?.volume=1.0
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
                print("Recording successful. File saved at: \(recordingURL?.path ?? "Unknown path") and fileSize: \(fileSize)")
                
                // test for the audio file
                do {
                    try audioSession.setCategory(.playback)
                    playBack()
                }catch{
                    print("Playing error \(error.localizedDescription)")
                }
               
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
        }else{
            print("Play finished unsucceed")
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

