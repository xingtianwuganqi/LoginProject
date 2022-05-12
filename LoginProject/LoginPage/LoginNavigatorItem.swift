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
