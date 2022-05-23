//
//  Github.swift
//  
//
//  Created by a on 2022/05/22.
//

import Foundation
import Alamofire

final class Github {
    public static let shared = Github()
    
    private let githubApiKey = ProcessInfo.processInfo.environment["GITHUB_API_KEY"]
    
    enum Error {
        case notFound, parseError
    }
    
    private init() {
        
    }
    
    func fetchRepository(repository: String, completion: @escaping (Error?, [Pull]?) -> ()) {
        var headers: HTTPHeaders = []
        if let api = githubApiKey {
            headers["Authorization"] = "token \(api)"
        }
        AF.request("https://api.github.com/repos/\(repository)/pulls?state=open", method: .get, headers: headers)
            .response { response in
                guard let data = response.data else { return }
                print(String(data: data, encoding: .utf8) ?? "")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let pulls = try? decoder.decode([Pull].self, from: data) else {
                    guard let error = try? decoder.decode(PullError.self, from: data) else {
                        completion(.parseError, nil)
                        return
                    }
                    if error.message == .notFound {
                        completion(.notFound, nil)
                    } else {
                        completion(.parseError, nil)
                    }
                    return
                }
                completion(nil, pulls)
            }
    }
}
