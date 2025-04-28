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
       SNFlowChain(actios: [
            self.showVCA(),
            self.showVCB()
        ], finished: {
            print("完成")
        }).start()
    }
    
    func showVCA() -> SNFlowChain.Action {
        return SNFlowChain.Action { actionContext in
            let a = A {
                actionContext(.next)
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
                        getSceneDelegate()?.window?.rootViewController = UIViewController()
                        actionContext(.finished)
                    }
                }
            }
        }
    }
}

func getSceneDelegate() -> SceneDelegate?{
    guard Thread.isMainThread else {return nil}
    guard let scene = UIApplication.shared.connectedScenes.first else {return nil}
    guard let sceneDelegate = scene.delegate as? SceneDelegate else {return nil}
    return sceneDelegate
}

func getAppDelegate() -> AppDelegate?{
    guard Thread.isMainThread else {return nil}
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
    return appDelegate
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
