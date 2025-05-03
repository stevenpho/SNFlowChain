//
//  Global.swift
//  SNFlowChain
//
//  Created by Lee Steve on 2025/5/4.
//
import UIKit

struct Global {
    static func getSceneDelegate() -> SceneDelegate?{
        guard Thread.isMainThread else {return nil}
        guard let scene = UIApplication.shared.connectedScenes.first else {return nil}
        guard let sceneDelegate = scene.delegate as? SceneDelegate else {return nil}
        return sceneDelegate
    }
    
    static func getAppDelegate() -> AppDelegate?{
        guard Thread.isMainThread else {return nil}
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        return appDelegate
    }
    
    static func setRootViewController(_ viewController: UIViewController){
        guard Thread.isMainThread else {return}
        guard let appDelegate = getSceneDelegate() else {return}
        appDelegate.window?.rootViewController = viewController
    }
}
