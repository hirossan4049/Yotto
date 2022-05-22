//
//  Command.swift
//  
//
//  Created by a on 2022/05/22.
//

import Foundation

protocol CommandOutput {
    func command(channel: String, msg: String, error: Bool)
}

extension CommandOutput {
    func command(channel: String, msg: String) {
        self.command(channel: channel, msg: msg, error: false)
    }
}

enum Commands: String, CaseIterable {
    case help = "help"
    case ping = "ping"
    case subscribe = "subscribe"
    case unsubscribe = "unsubscribe"
    case list = "list"
    
    func getDescription() -> String {
        switch self {
        case .ping:
            return "pong!"
        case .help:
            return "これだにょ"
        case .subscribe:
            return "監視するリポジトリを追加します owner/repo"
        case .unsubscribe:
            return "リポジトリを監視対象外にします owner/repo"
        case .list:
            return "監視しているリポジトリ一覧を表示します"
        }
    }
}

final class Command {
    var delegate: CommandOutput?
    
    private let ls = LocalStorage.shared
    
    func input(channel: String, flag: Commands, arg: [String]?) {
        print("flag: \(flag), arg: \(arg ?? []), channel: \(channel)")
        switch flag {
        case .ping:
            ping(channel: channel)
        case .help:
            help(channel: channel)
        case .subscribe:
            guard let repoName = arg?[safe: 0] else {
                delegate?.command(channel: channel, msg: "引数が足りません。 owner/repo", error: true)
                return
            }
            subscribe(channel: channel, repositoryName: repoName)
        case .unsubscribe:
            guard let repoName = arg?[safe: 0] else {
                delegate?.command(channel: channel, msg: "引数が足りません。 owner/repo", error: true)
                return
            }
            unsubscribe(channel: channel, repositoryName: repoName)
        case .list:
            getList(channel: channel)
        }
    }
    
    private func ping(channel: String) {
        delegate?.command(channel: channel, msg: "pong!")
    }
    
    private func help(channel: String) {
        let cmds = Commands.allCases
        var msg = ""
        cmds.forEach {
            msg.append(contentsOf: "\($0.rawValue) \(String(repeating: " ", count: 10 - $0.rawValue.count)): \($0.getDescription())\n")
        }
       delegate?.command(channel: channel, msg: "```\(msg)```")
   }
    
    private func subscribe(channel: String, repositoryName: String) {
        // TODO: 存在するリポジトリか
        if ls.storage.subscribedRepositories.filter({ $0 == repositoryName }).count != 0 {
            delegate?.command(channel: channel, msg: "`\(repositoryName)`は既に登録済みです。", error: true)
            return
        }
        ls.storage.subscribedRepositories.append(repositoryName)
        delegate?.command(channel: channel, msg: "`\(repositoryName)`を監視登録しました。")
    }
    
    private func unsubscribe(channel: String, repositoryName: String) {
        guard let index = ls.storage.subscribedRepositories.firstIndex(of: repositoryName) else {
            delegate?.command(channel: channel, msg: "`\(repositoryName)`は登録されていませんでした。", error: true)
            return
        }
        ls.storage.subscribedRepositories.remove(at: index)
        delegate?.command(channel: channel, msg: "`\(repositoryName)`を監視対象外にしました！")
        
    }
    
    private func getList(channel: String) {
        let msg = "監視中のリポジトリ \n```" + ls.storage.subscribedRepositories.joined(separator: "\n") + "```"
        delegate?.command(channel: channel, msg: msg)
    }
}
