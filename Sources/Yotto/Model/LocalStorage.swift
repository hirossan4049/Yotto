//
//  LocalStorage.swift
//  
//
//  Created by a on 2022/05/22.
//

import Foundation

struct LS: Codable {
    var test: String?
    var subscribedRepositories: [String]
    var users: [String: String] // [githubUsername: slackUsername]
    
//    struct User: Codable {
//        var slackId: String?
//        var
//    }
}

final class LocalStorage {
    static let shared = LocalStorage()
    private let fileManager = FileManager.default
    private let localStoragePath = ProcessInfo.processInfo.environment["LOCAL_STORAGE_PATH"] ?? "./localStorage.json"
    
    var storage: LS {
        get {
            let decoder = JSONDecoder()
            let fileUrl = URL(fileURLWithPath: localStoragePath)
            if !fileManager.fileExists(atPath: localStoragePath) {
                return LS(subscribedRepositories: [], users: [:])
            }
            guard let decoded = try? decoder.decode(LS.self, from: Data(contentsOf: fileUrl)) else {
                print("\(#line): パースエラー！")
                return LS(subscribedRepositories: [], users: [:])
            }
            return decoded
        }
        
        set(v) {
            if !fileManager.fileExists(atPath: localStoragePath) {
                print("file not found")
                fileManager.createFile(atPath: localStoragePath, contents: nil)
            }
            let encoder = JSONEncoder()
            guard let json = try? encoder.encode(v) else { return }
            let fileUrl = URL(fileURLWithPath: localStoragePath)
            try! json.write(to: fileUrl)
        }
    }
        
    private init() {
        print("localStoragePath: ", localStoragePath)
    }
}
