//
//  SNFlowChainVer1.swift
//  SNFlowChain
//
//  Created by Lee Steve on 2025/5/1.
//
//MARK: Version-1
//class SNFlowChain {
//
//    enum Queue : Equatable {
//        case main
//        case global
//        case none
//    }
//
//    @discardableResult
//    static func start() -> SNFlowChain {
//        return SNFlowChain()
//    }
//
//    typealias StepBlock = (@escaping (_ isContiune: Bool) -> Void) -> Void
//    typealias CatchBlock = (Error) -> Void
//    typealias FinallyBlock = () -> Void
//    private var id = 0
//    private var queue : Queue = .none
//    private var currentStep: StepBlock?
//    private var lastChain: SNFlowChain?
//    private var nextChain: SNFlowChain?
//    private var finallyBlock: FinallyBlock?
//    private var delaySeconds: TimeInterval?
//    private var conditionCheck: (() -> Bool)?
//    private var logMessage: String?
//
//    init() {}
//
//    @discardableResult
//    func commit() -> SNFlowChain {
//        // 找到最早的 chain 開始點
//        var root: SNFlowChain = self
//        while let previous = root.lastChain {
//            root = previous
//        }
//        // 執行第一個
//        root.execute(shouldContinue: true)
//        return self
//    }
//
//    @discardableResult
//    func then(_ step: @escaping StepBlock) -> SNFlowChain {
//        let next = SNFlowChain()
//        next.lastChain = self
//        next.id = self.id + 1
//        self.currentStep = step
//        self.nextChain = next
//        return next
//    }
//
//    @discardableResult
//    func finally(_ handler: @escaping FinallyBlock) -> SNFlowChain {
//        self.finallyBlock = handler
//        self.lastChain?.finally(handler)
//        return self
//    }
//
//    @discardableResult
//    func delay(seconds: TimeInterval) -> SNFlowChain {
//        self.delaySeconds = seconds
//        return self
//    }
//
//    @discardableResult
//    func `if`(condition: @escaping () -> Bool) -> SNFlowChain {
//        self.conditionCheck = condition
//        return self
//    }
//
//    @discardableResult
//    func queue(_ queue: Queue) -> SNFlowChain {
//        self.queue = queue
//        return self
//    }
//
//    @discardableResult
//    func log(message: String) -> SNFlowChain {
//        self.logMessage = message
//        return self
//    }
//
//    private func executeFinallyBlock() {
//        self.finallyBlock?()
//        self.destroy()
//    }
//
//    private func destroy() {
//
//        if (self.currentStep != nil) {
//            self.currentStep = nil
//        }
//
//        if (self.finallyBlock != nil) {
//            self.finallyBlock = nil
//        }
//
//        if (self.conditionCheck != nil) {
//            self.conditionCheck = nil
//        }
//
//        if (self.lastChain != nil) {
//            self.lastChain?.destroy()
//            return
//        }
//    }
//
//    private func showLogMessage() {
//        guard let message = self.logMessage else {return}
//        print("[LOG] \(message)")
//    }
//
//    private func execute(shouldContinue: Bool) {
//        // Log Message
//        self.showLogMessage()
//
//        guard shouldContinue else {
//            self.executeFinallyBlock()
//            return
//        }
//
//        // Condition Check
//        guard let condition = self.conditionCheck else {
//            self.checkRunDealyIfNeeded()
//            return
//        }
//
//        guard condition() else {
//            self.executeFinallyBlock()
//            return
//        }
//
//        self.checkRunDealyIfNeeded()
//    }
//
//    private func checkRunDealyIfNeeded() {
//        switch self.queue {
//        case .main:
//            // Delay
//            guard let delay = self.delaySeconds else {
//                self.runOnMain { [weak self] in
//                    self?.runStep()
//                }
//                return
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                self.runStep()
//            }
//        case .global:
//            // Delay
//            guard let delay = self.delaySeconds else {
//                self.runOnGlobal { [weak self] in
//                    self?.runStep()
//                }
//                return
//            }
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//                self.runStep()
//            }
//        case .none:
//            // Delay
//            guard let delay = self.delaySeconds else {
//                self.runStep()
//                return
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                self.runStep()
//            }
//        }
//    }
//
//    private func runStep() {
//        guard let step = self.currentStep else {
//            self.executeFinallyBlock()
//            return
//        }
//
//        step { [weak self] shouldContinue in
//            guard let self = self else { return }
//            guard shouldContinue else {
//                self.executeFinallyBlock()
//                return
//            }
//            if let nextChain = self.nextChain {
//                nextChain.execute(shouldContinue: true)
//                return
//            }
//            self.executeFinallyBlock()
//        }
//    }
//
//    private func runOnGlobal(_ block: @escaping () -> Void) {
//        guard !Thread.isMainThread else {
//            DispatchQueue.global().async { block() }
//            return
//        }
//        block()
//    }
//
//    private func runOnMain(_ block: @escaping () -> Void) {
//        guard Thread.isMainThread else {
//            DispatchQueue.main.async { block() }
//            return
//        }
//        block()
//    }
//}
