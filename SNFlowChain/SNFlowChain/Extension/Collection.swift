//
//  Collection.swift
//  SNFlowChain
//
//  Created by Lee Steve on 2025/4/29.
//

extension Collection {
    
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
