//
//  SNFlowChain.swift
//  SNFlowChain
//
//  Created by Lee Steve on 2025/4/23.
//

import Foundation

class SNFlowChain {
    @discardableResult
    static func start() -> SNFlowChain {
        return SNFlowChain()
    }
    
    typealias StepBlock = (@escaping (_ isContiune: Bool) -> Void) -> Void
    typealias CatchBlock = (Error) -> Void
    typealias FinallyBlock = () -> Void
    private var id = 0
    private var currentStep: StepBlock?
    private var lastChain: SNFlowChain?
    private var nextChain: SNFlowChain?
    private var finallyBlock: FinallyBlock?
    private var delaySeconds: TimeInterval?
    private var conditionCheck: (() -> Bool)?
    private var logMessage: String?
    
    init() {}
    
    @discardableResult
    func then(_ step: @escaping StepBlock) -> SNFlowChain {
        if (self.id == 0 && self.conditionCheck?() == false) {
            self.finallyBlock?()
            return self
        }
        let next = SNFlowChain()
        next.lastChain = self
        next.id = self.id + 1
        self.currentStep = step
        self.nextChain = next
        if (self.id == 0){
            step { isContiune in
                next.execute(shouldContinue: isContiune)
            }
        } else {
            next.currentStep = step
            next.nextChain = next
        }
        return next
    }
    
    @discardableResult
    func finally(_ handler: @escaping FinallyBlock) -> SNFlowChain {
        self.finallyBlock = handler
        self.lastChain?.finally(handler)
        return self
    }
    
    @discardableResult
    func delay(seconds: TimeInterval) -> SNFlowChain {
        self.delaySeconds = seconds
        return self
    }
    
    @discardableResult
    func `if`(condition: @escaping () -> Bool) -> SNFlowChain {
        self.conditionCheck = condition
        return self
    }
    
    @discardableResult
    func log(message: String) -> SNFlowChain {
        self.logMessage = message
        if (self.id == 0 && (self.conditionCheck?() == true || self.conditionCheck == nil)){
            self.showLogMessage()
        }
        return self
    }
    
    private func showLogMessage() {
        guard let message = self.logMessage else {return}
        print("[LOG] \(message)")
    }
    
    private func execute(shouldContinue: Bool? = nil) {
        // Log Message
        self.showLogMessage()
        
        if (shouldContinue == false){
            self.finallyBlock?()
            return
        }
        // Condition Check
        guard let condition = self.conditionCheck, condition() else {
            self.finallyBlock?()
            return
        }
        // Delay
        guard let delay = self.delaySeconds else {
            //self.runOnMain {
                self.runStep()
            //}
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.runStep()
        }
    }
    
    private func runStep() {
        guard let step = self.currentStep else {
            self.finallyBlock?()
            return
        }
        step { [weak self] shouldContinue in
            guard let self = self else { return }
            if shouldContinue {
                if let nextChain = self.nextChain {
                    nextChain.execute()
                    return
                }
                self.finallyBlock?()
            } else {
                self.finallyBlock?()
            }
        }
    }
    
    private func runOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async { block() }
        }
    }
}
