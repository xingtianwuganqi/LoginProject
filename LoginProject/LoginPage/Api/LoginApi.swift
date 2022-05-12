//
//  LoginApi.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/15.
//

import Foundation
import Moya
import BasicProject

public enum LoginApi {
    case login(phone: String?,pswd: String)
    case register(phone: String?, pswd: String,confirm: String)
    case updateAccount(phone: String?, pswd: String,confirm: String)
    case getVerificationCode(phone: String)
    case checkCode(phone:String, code: String)
    case checkPhone(phone: String, code: String)
    case bindPhone(phone: String, code: String)
}

extension LoginApi: BaseTargetType {
    
    public var parameters: [String : Any] {
        var parameter: [String: Any] = APPCommonParam.apiBasicParameters()
        switch self {
        case .register(phone: let phone, pswd: let pswd, confirm: let confrim):
            parameter["phoneNum"] = phone
            parameter["password"] = pswd
            parameter["confirm_password"] = confrim
            parameter["phone_type"] = PhoneType.getDeviceModel()
        case .login(phone: let phone, pswd: let pswd):
            parameter["phoneNum"] = phone
            parameter["password"] = pswd
            parameter["phone_type"] = PhoneType.getDeviceModel()
        case .updateAccount(phone: let phone, pswd: let pswd, confirm: let confirm):
            parameter["phoneNum"] = phone
            parameter["password"] = pswd
            parameter["confirm_password"] = confirm
        case .getVerificationCode(phone: let phone):
            parameter["phone"] = phone
            parameter["code"] = Tool.shared.encryptionString(codeStr: CodeStr)
        case .checkCode(phone: let phone, code: let code):
            parameter["phone"] = phone
            parameter["code"] = code
        case .checkPhone(phone: let phone, code: let code):
            parameter["token"] = UserManager.shared.token
            parameter["phone"] = phone
            parameter["code"] = code
        case .bindPhone(phone: let phone, code: let code):
            parameter["token"] = UserManager.shared.token
            parameter["phone"] = phone
            parameter["code"] = code
        }
        return parameter
    }

    
    public var path: String {
        switch self {
        case .login:
            return "/api/v1/login/"
        case .register:
            return "/api/v1/register/"
        case .updateAccount:
            return "/api/v1/updatepswd/"
        case .getVerificationCode:
            return "/api/v2/tecent/code/"
        case .checkCode:
            return "/api/v2/tecent/check/"
        case .checkPhone:
            return "/api/v2/login/checkphone/"
        case .bindPhone:
            return "/api/v2/login/bindphone/"
        }
    }
}
