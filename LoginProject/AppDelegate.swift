//
//  AppDelegate.swift
//  LoginProject
//
//  Created by jingjun on 2022/5/11.
//

import UIKit
import BasicProject
import URLNavigator

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let navi = Navigator()
        let naviService = NavigatorService.init(navigator: navi)
        let vc = TestViewController.init(navi: naviService)
//        let naviContorller = BaseNavigationController.init(rootViewController: vc)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }


}

