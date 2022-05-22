//
//  LocalStorage.swift
//  
//
//  Created by a on 2022/05/22.
//

import Foundation

struct LS: Codable {
    var test: String?
//    var subscribedRepositories: [String]
    
}

final class LocalStorage {
    static let shared = LocalStorage()
    let fileManager = FileManager.default
    let localStoragePath = ProcessInfo.processInfo.environment["LOCAL_STORAGE_PATH"] ?? "/home/localStorage.json"
    
    var storage: LS {
        get {
            let decoder = JSONDecoder()
            let fileUrl = URL(fileURLWithPath: localStoragePath)
            if !fileManager.fileExists(atPath: localStoragePath) {
                return LS()
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
    
//    func set() {
//        let encoder = JSONEncoder()
//        guard let json = try? encoder.encode(ls) else { return }
//        let localStoragePath = ProcessInfo.processInfo.environment["LOCAL_STORAGE_PATH"] ?? "/home/localStorage.json"
//        let fileUrl = URL(fileURLWithPath: localStoragePath)
//        try! json.write(to: fileUrl)
//    }
//
//    func get(key: LS.Type) {
//        let decoder = JSONDecoder()
//        guard let ls = try? decoder.decode(LS.self, from: "".data(using: .utf8)!) else { fatalError() }
//
//    }
}
