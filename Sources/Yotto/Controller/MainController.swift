//
//  MainController.swift
//  
//
//  Created by a on 2022/05/22.
//

import Foundation
import SlackKit

class MainController {
    private let slackApiKey: String
    private let slackkit = SlackKit()
    private let command = Command()
    
    init() {
        guard let slackApiKey = ProcessInfo.processInfo.environment["SLACK_API_KEY"] else { fatalError("Slack APIキーがありません。") }
        self.slackApiKey = slackApiKey
        command.delegate = self
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

        slackkit.addRTMBotWithAPIToken(slackApiKey)
        slackkit.addWebAPIAccessWithToken(slackApiKey)
        
        slackkit.notificationForEvent(.message) { [weak self] (event, client) in
            self?.listen(client?.client,message: event.message)
        }
        
        RunLoop.main.run()
    }
    
    private func listen(_ client: Client?, message: Message?) {
        guard let _ = client,
              let message = message,
              var cmd = message.text?.components(separatedBy: " "),
              let channel = message.channel
        else {
            return
        }
        if cmd.remove(at: 0) == "yotto" {
            let flag = cmd.remove(at: 0)
            if let flag = Commands(rawValue: String(flag)) {
                command.input(channel: channel, flag: flag, arg: cmd)
                return
            }
        } else {
            return
        }
        
        send(channel: channel, msg: "解析に失敗しました。 `yotto help` を参照してください。")
    }
    
    func send(channel: String, msg: String) {
        slackkit.webAPI?.sendMessage(
            channel: channel,
            text: msg,
            username: "Yotto",
            iconURL:  "https://images.pexels.com/photos/5302577/pexels-photo-5302577.jpeg?auto=compress&cs=tinysrgb&w=512&h=512",
            success: nil,
            failure: { (error) in
                print("メッセージ送信失敗:\(error)")
            }
        )
    }
}

extension MainController: CommandOutput {
    func command(channel: String, msg: String, error: Bool = false) {
        if error {
            send(channel: channel, msg: ":warning:エラー: \(msg):warning:")
        } else {
            send(channel: channel, msg: msg)
        }
    }
}
