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
    case testrun = "testrun"
    case addUser = "add-user"
    case addUsers = "add-users"
    case getUsers = "get-users"
    case remind = "remind"
    
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
        case .testrun:
            return "テスト実行します"
        case .addUser:
            return "GitHubのユーザー名からSlackのメンションに変換するユーザーを登録できます GitHubUser/SlackUserID"
        case .addUsers:
            return "`add-user` を複数一気に登録できます GitHubUser1/SlackUserID1 GitHubUser2/SlackUserID2..."
        case .getUsers:
            return "GitHubのユーザー名からSlackのメンションに変換するユーザー一覧を表示します"
        case .remind:
            return "リマインドします HH:MM {weekday}"
        }
    }
}

final class Command {
    var delegate: CommandOutput?
    
    private let ls = LocalStorage.shared
    private let gh = Github.shared
    
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
        case .testrun:
            testrun(channel: channel, repository: arg)
        case .addUser:
            guard let usernames = arg?[safe: 0] else {
                delegate?.command(channel: channel, msg: "引数が足りません。 GitHubUser/SlackUser", error: true)
                return
            }
            if !setUser(channel: channel, usernames: usernames) {
                delegate?.command(channel: channel, msg: "引数がおかしいです。 GitHubUser/SlackUser", error: true)
            } else {
                delegate?.command(channel: channel, msg: "追加しました👍")
            }
        case .addUsers:
            guard let arg = arg else {
                delegate?.command(channel: channel, msg: "引数が足りません。 GitHubUser/SlackUser", error: true)
                return
            }
            for user in arg {
                if !setUser(channel: channel, usernames: user) {
                    delegate?.command(channel: channel, msg: "引数がおかしいです。 GitHubUser/SlackUser", error: true)
                    return
                }
            }
            delegate?.command(channel: channel, msg: "追加しました👍")
        case .getUsers:
            var msg = "```\n"
            for (gh, sl) in ls.storage.users {
                msg += "\(gh)\(String(repeating: " ", count: max(15 - gh.count, 0))): \(sl)\n"
            }
            msg += "```"
            delegate?.command(channel: channel, msg: msg)
        case .remind:
            delegate?.command(channel: channel, msg: "未実装", error: true)
        }
    }
    
    /// MARK: COMMANDS
    private func ping(channel: String) {
        delegate?.command(channel: channel, msg: "pong!")
    }
    
    private func help(channel: String) {
        let cmds = Commands.allCases
        var msg = ""
        cmds.forEach {
            msg.append(contentsOf: "\($0.rawValue) \(String(repeating: " ", count: max(15 - $0.rawValue.count, 0))): \($0.getDescription())\n")
        }
        delegate?.command(channel: channel, msg: "```\(msg)```")
    }
    
    private func subscribe(channel: String, repositoryName: String) {
        if ls.storage.subscribedRepositories.filter({ $0 == repositoryName }).count != 0 {
            delegate?.command(channel: channel, msg: "`\(repositoryName)`は既に登録済みです。", error: true)
            return
        }
        gh.fetchRepository(repository: repositoryName, completion: { [weak self] error, pulls in
            guard let self = self else { return }
            
            if let error = error {
                let errorMsg = error == .parseError ? "解析エラー" : error == .notFound ? "リポジトリが存在しないか、権限がないか、GithubのAPIキーが間違っています。" : "謎のエラー"
                self.delegate?.command(channel: channel, msg: errorMsg, error: true)
                return
            }
            self.ls.storage.subscribedRepositories.append(repositoryName)
            self.delegate?.command(channel: channel, msg: "`\(repositoryName)`を監視登録しました。")
        })
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
        var msg = ""
        if ls.storage.subscribedRepositories.count == 0{
            msg = "監視中のリポジトリはありません"
        } else {
            msg = "監視中のリポジトリ \n```" + ls.storage.subscribedRepositories.joined(separator: "\n") + "```"
        }
        delegate?.command(channel: channel, msg: msg)
    }
    
    private func testrun(channel: String, repository: [String]? = []) {
        let repos = (repository?.count != 0) ? repository! : ls.storage.subscribedRepositories
        if repos.count == 0 {
            delegate?.command(channel: channel, msg: "リポジトリが登録されていません。 `yotto subscribe owner/repo` で登録できます。", error: true)
        }
        
        for repo in repos {
            // "Ax-Robotix/Pixx_iOSApp_for_FirstCabin"
            gh.fetchRepository(repository: repo, completion: { [weak self] error, pulls in
                guard let self = self else { return }
                var msg = ""
                
                if let error = error {
                    let errorMsg = error == .parseError ? "解析エラー" : error == .notFound ? "リポジトリが存在しないか、権限がないか、GithubのAPIキーが間違っています。" : "謎のエラー"
                    self.delegate?.command(channel: channel, msg: errorMsg, error: true)
                    return
                }
                guard let pulls = pulls else { return }
                
                if pulls.count == 0 {
                    msg += "── 🎉\(repo)にPRはありません🎉 ── \n\n"
                } else {
                    msg += "┌ 😈<https://github.com/\(repo)|\(repo)>に未完了タスクがあります😈 ┐ \n"
                    
                    msg += self.pullToReviewersSort(pulls: pulls)
                    
                    msg += "└────────────────────────────────────────────┘"
                }
                
                self.delegate?.command(channel: channel, msg: msg)
            })
        }
    }
    
    private func setUser(channel: String, usernames: String) -> Bool {
        let cmps = usernames.components(separatedBy: "/")
        if let github = cmps[safe:0], let slack = cmps[safe: 1] {
            if slack.contains("<@") {
                ls.storage.users[github] = slack
            } else {
                ls.storage.users[github] = "<@\(slack)>"
            }
            return true
        } else {
            return false
        }
    }
    
    /// MARK: TOOLS
    private func pullToReviewersSort(pulls: [Pull]) -> String {
        var unknownReviews: [Pull] = []
        var reviewers: [String: [Pull]] = [:]
        for pull in pulls {
            if pull.requestedReviewers.count == 0 {
                unknownReviews.append(pull)
                continue
            }
            pull.requestedReviewers.forEach({
                if reviewers[$0.login] == nil {
                    reviewers[$0.login] = [pull]
                } else {
                    reviewers[$0.login]?.append(pull)
                }
            })
        }
        
        var msg = ""
        
        for (name, namePulls) in reviewers {
            msg += "　 *\(githubName2SlackName(name))にレビューしてほしいPR* \n"
            namePulls.forEach({
                msg += "　　・ <\($0.url)|\($0.title)> \n"
            })
            msg += "　\n"
        }
        
        msg += "　 *レビュワーが不在です。割り当ててください* \n"
        for review in unknownReviews {
            msg += "　　・ <\(review.url)|\(review.title)> \(githubName2SlackName(review.user.login)) \n"
        }
        
        return msg
    }
    
    private func githubName2SlackName(_ name: String) -> String {
        return ls.storage.users[name] ?? name
    }
    
}
