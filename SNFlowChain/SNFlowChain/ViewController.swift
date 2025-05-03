//
//  ViewController.swift
//  SNFlowChain
//
//  Created by Lee Steve on 2025/4/23.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var shouldShow = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Example: 1
//        SNFlowChain(actios: [
//            .log("1"),
//            self.showVCA(),
//            .if(condition: {
//                return true
//            }),
//            .log("2"),
//            self.showVCB(),
//            .then(onQueue: .main(createStyle: .new)) {
//                self.view.backgroundColor = .green
//            }
//        ], finished: {
//            print("完成")
//            self.view.backgroundColor = .red
//        }).start()
        
        // Example: 2
//        SNFlowChain.builder(actios: {
//            SNAction.log("1")
//            SNAction.then {
//                self.view.backgroundColor = .blue
//            }
//            SNAction.log("2")
//            SNAction.delay(onQueue: .main, seconds: 3)
//            SNAction.log("--------")
//            
//            SNAction.log("3")
//            
//            SNAction { actionContext in
//                self.view.backgroundColor = .yellow
//                actionContext(.onStop)
//            }
//        }, finished: {
//            print("完成")
//            self.view.backgroundColor = .red
//        }).start()
        
        // Ecample 3
        SNFlowChain(builderActios: {
            SNAction.log("1")
            SNAction.then(onQueue: .main(createStyle: .new)) {
                self.view.backgroundColor = .blue
            }
            SNAction.log("2")
            SNAction.if {
                return true
            }
            SNAction.log("2.5")
            SNAction.delay(onQueue: .main(createStyle: .none), seconds: 3)
            SNAction.log("--------")
            
            SNAction.log("3")
            
            SNAction { actionContext in
                print("stop")
                self.view.backgroundColor = .yellow
                actionContext(.onStop)
            }
        }, finished: {
            print("完成")
        }).start()
        
        //Global.setRootViewController(UIViewController())
        // Example4
    }
    
    func showVCA() -> SNFlowChain.Action {
        return SNFlowChain.Action { actionContext in
            let a = A {
                actionContext(.onNext)
            }
            self.present(a, animated: true)
        }
    }
    
    func showVCB() -> SNFlowChain.Action {
        return SNFlowChain.Action { actionContext in
            let b = B()
            b.view.backgroundColor = .green
            self.present(b, animated: true)
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        Global.setRootViewController(UIViewController())
                        actionContext(.onFinished)
                    }
                }
            }
        }
    }
}

class A: UIViewController {
    var didDissmiss: (() -> Void)? = nil
    
    lazy var button : UIButton = {
       let node = UIButton()
        node.backgroundColor = .green
        return node
    }()
    
    init(didDissmiss: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.didDissmiss = didDissmiss
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.view.addSubview(self.button)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
        self.button.addTarget(self, action: #selector(self.buttonPress), for: .touchUpInside)
        NSLayoutConstraint.activate([
            self.button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.button.widthAnchor.constraint(equalToConstant: 100),
            self.button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @objc func buttonPress() {
        self.dismiss(animated: true) {
            self.didDissmiss?()
        }
    }
    
}

class B: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
