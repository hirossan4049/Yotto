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
                return LS(subscribedRepositories: [])
            }
            return try! decoder.decode(LS.self, from: Data(contentsOf: fileUrl))
        }
        
        set(v) {
            if !fileManager.fileExists(atPath: localStoragePath) {
                fileManager.createFile(atPath: localStoragePath, contents: nil)
            }
            let encoder = JSONEncoder()
            guard let json = try? encoder.encode(v) else { return }
            let fileUrl = URL(fileURLWithPath: localStoragePath)
            try! json.write(to: fileUrl)
        }
    }
        
    private init() {
        
    }
}
