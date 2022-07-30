//
//  LoginNavigatorItem.swift
//  LoginProject
//
//  Created by jingjun on 2022/5/12.
//

import Foundation
import BasicProject

public enum LoginNavigatorItem: NavigatorItemType {
    case webProtocalPage(url: String)
    case register(phone: String)
    case changePswd(account: String)
    case checkCode(CodeFromType,String?)
}



public enum CodeFromType {
    case register
    case findPswd
    case bindPhone
    case checkPhone
}


public struct LGResourceBundle {
    static func getBundleByName(classClass: AnyClass,bundleName: String) -> Bundle? {
        let rootBundle = Bundle(for: classClass)
        guard let url = rootBundle.url(forResource: bundleName, withExtension: "bundle") else {
            return nil
        }
        guard let bundle = Bundle(url: url) else{
            return nil
        }
        return bundle
    }
    
    static func getImage(_ imageName: String) -> UIImage? {
        let image = UIImage.init(named: "\(imageName)@3x" , in: LGResourceBundle.getBundleByName(classClass: LoginViewController.self, bundleName: "LoginIconBundle"), compatibleWith: nil)
        return image
    }
}
