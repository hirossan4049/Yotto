//
//  Array+safe.swift
//  
//
//  Created by a on 2022/05/22.
//

extension Array {
    subscript (safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}
