//
//  Thread.swift
//  SNFlowChain
//
//  Created by Lee Steve on 2025/5/4.
//
import Foundation

extension Thread {
    class var isGlobalThread: Bool {
        return !Thread.isMainThread
    }
}
