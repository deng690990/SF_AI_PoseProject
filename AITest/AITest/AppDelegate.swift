//
//  AppDelegate.swift
//  AITest
//
//  Created by 邓升发 on 2020/4/29.
//  Copyright © 2020 com.YouMa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow.init()
        self.window?.makeKeyAndVisible()
        self.window?.frame = UIScreen.main.bounds
        self.window?.backgroundColor = UIColor.white
        self.setRootViewController(vc: ViewController.init())
        return true
    }
    func setRootViewController(vc:UIViewController) {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }

}

