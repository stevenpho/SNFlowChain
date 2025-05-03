//
//  SNFlowChain.swift
//  SNFlowChain
//
//  Created by Lee Steven on 2025/4/23.
//

import Foundation

typealias SNAction = SNFlowChain.Action


protocol SNActionFlowStep {
    var action: SNFlowChain.StepBlock { get }
}

/// 可以不需要加上 weak self 會自動釋放
// 不用擔心memory leak 因為是@escaping閉包 加上Action class會建立在父類別實體class上生命週期綁在上面
class SNFlowChain {
    let actios: [Action]
    let finished: FinishedBlock?
    var index = 0
    
    init(actios: [Action], finished: FinishedBlock? = nil) {
        self.actios = actios
        self.finished = finished
    }
    
    init(@SNFlowChainActionBuilder builderActios: () -> [Action], finished: FinishedBlock? = nil) {
        self.actios = builderActios()
        self.finished = finished
    }
    
    func start() {
        //print("start action: \(self.index)")
        guard let firstAction = self.actios[safe: self.index] else {
            self.finished?()
            return
        }
        firstAction.action { actionContext in
            //print(actionContext)
            switch actionContext {
            case .onNext:
                self.index += 1
                self.start()
                return
            case .onStop, .onFinished:
                self.finished?()
                return
            }
        }
    }
}

// MARK: Model
extension SNFlowChain {
    typealias FinishedBlock = () -> Void
    typealias StepBlock = (@escaping(_ actionContext: ActionStyle) -> Void) -> Void
    typealias ThenBlock = () -> Void
    typealias IfBlock = () -> Bool
    class Action {
        let action: StepBlock
        init(action: @escaping StepBlock) {
            self.action = action
        }
    }
    
    enum ActionStyle: Equatable {
        case onNext
        case onStop
        case onFinished
    }
    
    enum QueueStyle: Equatable {
        case main(createStyle: QueueCreateStyle)
        case global(createStyle: QueueCreateStyle)
        case none
    }
    
    enum QueueCreateStyle: Equatable {
        /// 建立新的async queue
        case new
        /// 沿用當前同個queue 如果不是目標的queue style會檢查來決定要不要建立新的queue
        case none
    }
}

// MARK: SNFlowChain Action Flow
extension SNFlowChain.Action {
    
    static func `if`(onQueue: SNFlowChain.QueueStyle = .none, condition: @escaping SNFlowChain.IfBlock) -> SNFlowChain.Action{
        return SNFlowChain.Action { actionStyle in
            switch condition() {
            case true:
                actionStyle(.onNext)
            case false:
                actionStyle(.onStop)
            }
        }
    }
    
    static func then(onQueue: SNFlowChain.QueueStyle = .none, action: @escaping SNFlowChain.ThenBlock) -> SNFlowChain.Action{
        return SNFlowChain.Action { actionStyle in
            let doAction = {
                action()
                actionStyle(.onNext)
            }
            switch onQueue {
            case .main(let createStyle):
                let doMainAction = {
                    DispatchQueue.main.async {
                        doAction()
                    }
                }
                switch createStyle {
                case .new:
                    doMainAction()
                case .none:
                    guard Thread.isMainThread else {
                        doMainAction()
                        return
                    }
                    doAction()
                }
            case .global(let createStyle):
                let doGlobalAction = {
                    DispatchQueue.global().async {
                        doAction()
                    }
                }
                switch createStyle {
                case .new:
                    doGlobalAction()
                case .none:
                    guard Thread.isGlobalThread else {
                        doGlobalAction()
                        return
                    }
                    doAction()
                }
            case .none:
                doAction()
            }
        }
    }
    
    static func log(_ items: Any...) -> SNFlowChain.Action{
        return SNFlowChain.Action { actionStyle in
            print("Log: \(items)")
            actionStyle(.onNext)
        }
    }
    
    static func delay(onQueue: SNFlowChain.QueueStyle, seconds: TimeInterval) -> SNFlowChain.Action{
        return SNFlowChain.Action { actionStyle in
            switch onQueue {
            case .main(let createStyle):
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    actionStyle(.onNext)
                }
            case .global(let createStyle):
                DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
                    actionStyle(.onNext)
                }
            case .none:
                actionStyle(.onNext)
            }
        }
    }
}

// MARK: SNFlowAction DSL Builder
@resultBuilder
struct SNFlowChainActionBuilder {
    static func buildBlock(_ actions: SNFlowChain.Action...) -> [SNFlowChain.Action] {
        return actions
    }
    
//    static func buildPartialBlock(first: SNFlowChain.Action) -> SNFlowChain.Action {
//        <#code#>
//    }
    
    static func buildOptional(_ component: SNFlowChain.Action?) -> SNFlowChain.Action {
        component ?? .then {}
    }
    
    static func buildEither(first component: SNFlowChain.Action) -> SNFlowChain.Action {
        component
    }
    
    static func buildEither(second component: SNFlowChain.Action) -> SNFlowChain.Action {
        component
    }
    
    static func buildExpression(_ expression: SNFlowChain.Action) -> SNFlowChain.Action {
        expression
    }
    
//    static func buildFinalResult(_ component: SNFlowChain) -> <#Result#> {
//        <#code#>
//    }
    
    static func buildArray(_ components: [SNFlowChain.Action]) -> [SNFlowChain.Action] {
        components
    }
    
    static func buildLimitedAvailability(_ component: SNFlowChain.Action) -> SNFlowChain.Action {
        component
    }
}
// MARK: SNFlowAction DSL Builder
extension SNFlowChain.Action {}


// MARK: SNFlowChain DSL Builder

extension SNFlowChain {
    // Test
//    @SNFlowChainBuilder
//    static func makeExampleBuilder() -> SNFlowChain {
//        SNFlowChain.Action { actionStyle in
//            actionStyle(.onNext)
//        }
//        SNFlowChain.Action { actionStyle in
//            actionStyle(.onFinished)
//        }
//    }
    /// Builder version use
    static func builder(@SNFlowChainActionBuilder actios: () -> [SNAction], finished: FinishedBlock? = nil) -> SNFlowChain {
        return SNFlowChain(actios: actios(), finished: finished)
    }
}

//@resultBuilder
//struct SNFlowChainBuilder {
//    static func buildBlock(_ actions: SNFlowChain.Action...) -> SNFlowChain {
//        return SNFlowChain(actios: actions)
//    }
//    
//    static func buildPartialBlock(first: SNFlowChain) -> SNFlowChain {
//        <#code#>
//    }
//    
//    static func buildOptional(_ component: SNFlowChain?) -> SNFlowChain {
//        <#code#>
//    }
//    
//    static func buildEither(first component: SNFlowChain) -> SNFlowChain {
//        <#code#>
//    }
//    
//    static func buildEither(second component: SNFlowChain) -> SNFlowChain {
//        <#code#>
//    }
//    
//    static func buildExpression(_ expression: <#Expression#>) -> SNFlowChain {
//        <#code#>
//    }
//    
//    static func buildFinalResult(_ component: SNFlowChain) -> <#Result#> {
//        <#code#>
//    }
//    
//    static func buildArray(_ components: [SNFlowChain]) -> SNFlowChain {
//        <#code#>
//    }
//    
//    static func buildLimitedAvailability(_ component: SNFlowChain) -> SNFlowChain {
//        <#code#>
//    }
//}




