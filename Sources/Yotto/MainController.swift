//
//  MainController.swift
//  
//
//  Created by a on 2022/05/22.
//

import Foundation
import SlackKit

class MainController {
//    private let slackApiKey: String
    
    init() {
//        guard let slackApiKey = ProcessInfo.processInfo.environment["SLACK_API_KEY"] else { fatalError("Slack APIキーがありません。") }
//        self.slackApiKey = slackApiKey
        print("launched")
    }
    
    deinit {
        print("deint")
    }
    
    func run() {
        let ls = LocalStorage.shared
        print(ls.storage)
        ls.storage.test = "olautan"
        print(ls.storage)
        sleep(100000)
        
        
//        Octokit().pullRequests(owner: "octocat", repository: "Hello-World", base: "develop", state: .open) { response in
//            switch response {
//                case .success(let pullRequests):
//                // do something with a pull request list
//                print(pullRequests)
//                case .failure:
//                // handle any errors
//            }
//        }

    }
}
