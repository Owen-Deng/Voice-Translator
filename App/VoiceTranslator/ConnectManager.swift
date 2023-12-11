//
//  ConnectManager.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation

let SERVER_URL = "http://192.168.50.219:8080" // change this for your server name!!!


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
 
//{host}/EZGenerate?text={text}&src_lang=en&tar_lang=zh&debug=False
        let urlString = "\(baseURL)/EZGenerate?text=\(text)&src_lang=\(srcLan)&tar_lang=\(tarLan)&debug=False"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        request.httpBody=audioData

        let task = session.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               // Process the response data
               if let data = data {
                   if let httpResponse = response as? HTTPURLResponse {
                       if httpResponse.statusCode == 200 {
                           print("recevied success \(data)")
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
