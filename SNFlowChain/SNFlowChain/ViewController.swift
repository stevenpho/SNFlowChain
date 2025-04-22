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
        SNFlowChain.start()
            .log(message: "start")
            .then {[weak self] isContinue in
            let a = A()
            a.didDissmiss = {
                isContinue(true)
            }
            self?.present(a, animated: true)
            }.delay(seconds: 3)
            .log(message: "start1")
            .if(condition: {[weak self] in
                return self?.shouldShow ?? false
            })
            .then {[weak self] isContinue in
            let a = A()
            a.didDissmiss = {
                isContinue(true)
            }
            self?.present(a, animated: true)
        }.finally {[weak self] in
            print("🎉 流程完成")
            self?.dismiss(animated: true)
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
