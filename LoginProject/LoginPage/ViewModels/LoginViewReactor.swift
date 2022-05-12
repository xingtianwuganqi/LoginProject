//
//  LoginViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/15.
//

import Foundation
import ReactorKit
import RxSwift
import BasicProject

public class LoginViewReactor: Reactor {
    public enum Action {
        case loginAction(phone: String?, pswd: String)
    }
    
    public enum Mutation {
        case empty
        case setLoading(Bool)
        case setLoginState(Bool,UserInfoModel?)
        case showErrorMsg(String?)
    }
    
    public struct State {
        public var isLoading: Bool = false
        public var isLogin: Bool = false
        public var userInfo: UserInfoModel?
        public var msg: String?
    }
    
    public var initialState: State
    let net = NetWorking<LoginApi>()
    public init() {
        self.initialState = State()
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loginAction(phone: let phone, pswd: let pswd):
            guard !self.currentState.isLoading else {
                return Observable.empty()
            }
            let loading = Observable.just(Mutation.setLoading(true))
            let netReq = self.netWorking(phone: phone, pswd: pswd).map { (model) -> Mutation in
                if model?.isSuccess == true {
                    return Mutation.setLoginState(true, model?.data)
                }else{
                    return Mutation.showErrorMsg(model?.message)
                }
            }.catchError { (error) -> Observable<Mutation> in
                return Observable.just(Mutation.showErrorMsg("网络错误"))
            }
            let endLoading = Observable.just(Mutation.setLoading(false))
            return Observable.concat([loading,netReq,endLoading])
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.msg = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
            
        case .setLoginState(let loginState,let userInfo):
            state.userInfo = userInfo
            state.isLogin = loginState
        case .showErrorMsg(let msg):
            state.msg = msg
        case .empty:
            break
        }
        return state
    }
}

extension LoginViewReactor {
    func netWorking(phone: String?, pswd: String) -> Observable<BaseModel<UserInfoModel>?> {
        let obj = net.request(.login(phone: phone, pswd: pswd.et.md5String))
        return obj.mapData(UserInfoModel.self)
    }
}
