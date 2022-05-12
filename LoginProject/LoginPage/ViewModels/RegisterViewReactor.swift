//
//  RegisterViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import ReactorKit
import BasicProject
final public class RegisterViewReactor: Reactor {
    
    public enum Action {
        case loginAndRegister(phone: String?, pswd: String,confrim: String)
    }
    
    public enum Mutation {
        case setLoading(Bool)
        case setLoginState(Bool,UserInfoModel?)
        case empty
        case showErrorMsg(String?)
    }
    
    public struct State {
        public var isLoading: Bool = false
        public var netError: Bool = false
        public var isLogin: Bool = false
        public var userInfo: UserInfoModel?
        public var msg: String?
    }
    
    public var initialState: State = State()
    let net = NetWorking<LoginApi>()

    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loginAndRegister(phone: let phone, pswd: let pswd, confrim: let confrim):
            guard !self.currentState.isLoading else {
                return Observable.empty()
            }
            let loading = Observable.just(Mutation.setLoading(true))
            let netReq = self.netWorking(phone: phone, pswd: pswd, confirm: confrim).map { (model) -> Mutation in
                if model?.isSuccess == true {
                    return Mutation.setLoginState(true,model?.data)
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
            
        case .setLoginState(let isLogin,let userInfo):
            state.isLogin = isLogin
            state.userInfo = userInfo
        case .showErrorMsg(let msg):
            state.msg = msg
        case .empty:
            break
        }
        return state
    }
}
extension RegisterViewReactor {
    func netWorking(phone: String?, pswd: String,confirm: String) -> Observable<BaseModel<UserInfoModel>?> {
        return net.request(.register(phone: phone, pswd: pswd.et.md5String, confirm: confirm.et.md5String)).mapData(UserInfoModel.self)
    }
}
