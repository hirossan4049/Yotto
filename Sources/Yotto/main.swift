//
//  main.swift
//
//
//  Created by a on 2022/05/22.
//
import Foundation

#if DEBUG
func setEnv() {
    let url = URL(fileURLWithPath: "/Users/a/Documents/fun/pg/Ax/Yotto/.env")
    guard let data = try? Data(contentsOf: url) else { return }
    guard let str = String(data: data, encoding: .utf8) else { return }
    let clean = str.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
    let envVars = clean.components(separatedBy:"\n")
    for envVar in envVars {
        let keyVal = envVar.components(separatedBy:"=")
        if keyVal.count == 2 {
            setenv(keyVal[0], keyVal[1], 1)
        }
    }
}
setEnv()
#endif

MainController().run()
