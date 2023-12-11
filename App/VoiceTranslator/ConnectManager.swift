//
//  ConnectManager.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation

let SERVER_URL = "http://192.168.50.247:8080" // change this for your server name!!!


class ConnectManager: NSObject, URLSessionDelegate{
    // MARK: Class Properties
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
                          delegate: self,
                          delegateQueue:self.operationQueue)
    }()
    let operationQueue = OperationQueue()
    
    static let shared=ConnectManager()
    private let baseURL:String
    
    private override init(){
        baseURL=SERVER_URL;  // todo to change the url
    }
    
    func sendGetRequest(endpoint: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = self.session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                print("sendGetRequest\(error)")
            } else if let data = data {
                completion(.success(data))
            }
        }
        
        task.resume()
    }
    
    func sendPostRequest(endpoint: String, jsonData: Data, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
        
        task.resume()
    }
    
    
    func sendAudioPostRequest(srcLan:String, tarLan:String,text: String, audioData: Data, completion: @escaping (Result<Data, Error>) -> Void) {
           let urlString = "\(SERVER_URL)/EZGenerate"

           guard let url = URL(string: urlString) else {
               completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
               return
           }
           var request = URLRequest(url: url)
           request.httpMethod = "POST"

           // Set the request parameters
           let params = [
               "text": text,
               "src_lang": srcLan,
               "tar_lang": tarLan,
               "debug": "False"
           ]

           request.httpBody = try? JSONSerialization.data(withJSONObject: params)

           // Set up the request headers
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           let boundary = "Boundary-\(UUID().uuidString)"
           request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

           var body = Data()

           // Append text data
            
        body.append(Data("--\(boundary)\r\n".utf8)) // only append the data type
        body.append(Data("Content-Disposition: form-data; name=\"text\"\r\n\r\n".utf8))
        body.append(text.data(using: .utf8)!)
        body.append(Data("\r\n".utf8))

           // Append audio data
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"audio\"; filename=\"myAudioFile.wav\"\r\n".utf8))
        body.append(Data("Content-Type: audio/mpeg\r\n\r\n".utf8))
        body.append(audioData)
        body.append(Data("\r\n".utf8))

           // Close the body with the boundary
        body.append(Data("--\(boundary)--\r\n".utf8))

        request.httpBody = body

        let task = session.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               // Process the response data
               if let data = data {
                   if let httpResponse = response as? HTTPURLResponse {
                       if httpResponse.statusCode == 200 {
                           completion(.success(data))
                       } else {
                           completion(.failure(NSError(domain: "HTTP Response Code: \(httpResponse.statusCode)", code: httpResponse.statusCode, userInfo: nil)))
                       }
                   }
               }
        }

        // Add progress tracking
        let progressObserver = task.progress.observe(\.fractionCompleted) { progress, _ in
                print("Upload progress: \(progress.fractionCompleted * 100)%")
        }
        task.addObserver(progressObserver, forKeyPath: "progress", options: .new, context: nil)

        task.resume()
    }
    
}

enum NetworkError: Error {
    case invalidURL
}
