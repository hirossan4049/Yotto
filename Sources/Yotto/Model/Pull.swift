//
//  Pull.swift
//  
//
//  Created by a on 2022/05/22.
//

struct Pull: Codable {
    let url: String
    let id: Int
    let number: Int
    let state: State
    let title: String
    let body: String
    let user: User
    let requestedReviewers: [User]
    
    enum State: String, Codable {
        case open = "open"
        case close = "close"
    }
    
    struct User: Codable {
        let id: Int
        let login: String // username
        let avatarUrl: String
    }
    
    struct Repo: Codable {
        let id: Int
        let name: String // リポジトリ名
        let fullName: String // フルリポジトリ名 USER/REPO
    }
}
