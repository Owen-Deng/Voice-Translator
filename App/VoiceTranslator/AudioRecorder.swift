//
//  AudioRecorder.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var recordingCompletion: ((URL?, Double) -> Void)?

    override init() {
        super.init()
        setupAudioRecorder()
    }

    func setupAudioRecorder() {
        // Set up audio session
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
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
            if let fileSize=getFileSize(url: recordingURL){
                print("StopRecording success:\(fileSize)")
            }
            
        }else{
            print("StopRecording fail")
        }
    }
    
    func playRecordAudio(){
        
    }
    
    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording successful. File saved at: \(recordingURL?.path ?? "Unknown path")")
            if let fileSize = getFileSize(url: recordingURL) {
                recordingCompletion?(recordingURL, fileSize)
            }
        } else {
            print("Recording failed.")
            recordingCompletion?(nil, 0.0)
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

