//
//  PullError.swift
//
//  Created by a on 2022/05/23.
//

import Foundation

struct PullError: Codable {
    let message: Message
    let documentationUrl: String
    
    enum Message: String, Codable {
        case notFound = "Not Found"
    }
}
