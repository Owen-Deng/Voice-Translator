//
//  ConnectManager.swift
//  VoiceTranslator
//
//  Created by RongWei Ji on 12/5/23.
//

import Foundation

let SERVER_URL = "http://192.168.50.247:8000" // change this for your server name!!!
let SERVER_URL_FAST="http://192.168.50.247:8080"  // for the faster api

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
        baseURL=SERVER_URL_FAST;  // todo to change the url
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
    
}

enum NetworkError: Error {
    case invalidURL
}
