//
//  FindPswdChangeReactor.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import Foundation
import ReactorKit
import BasicProject
final public class FindPswdChangeReactor: Reactor {
    
    public enum Action {
        case changePswd(phone: String, pswd: String,confrim: String)
    }
    
    public enum Mutation {
        case setLoading(Bool)
        case setChangeState(Bool,String?)
    }
    
    public struct State {
        public var isLoading: Bool = false
        public var netError: Bool = false
        public var account: String
        public var errorMsg: String?
        public var changeResult: Bool?
    }
    
    public var initialState: State
    public var networking = NetWorking<LoginApi>()
    public init(account: String) {
        self.initialState = State.init(account: account)
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changePswd(phone: let phone, pswd: let pswd, confrim: let confirm):
            guard !currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.changePswdNetworking(phone: phone, pswd: pswd, confirm: confirm).map { baseModel -> Mutation in
                if baseModel?.code == 200 {
                    return Mutation.setChangeState(true,nil)
                }else{
                    return Mutation.setChangeState(false, baseModel?.message ?? "找回失败")
                }
            }.catchError { error -> Observable in
                return Observable.just(Mutation.setChangeState(false, "网络错误"))
            }
            return Observable.concat([start,request,end])
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMsg = nil
        state.changeResult = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .setChangeState(let result, let msg):
            state.changeResult = result
            state.errorMsg = msg
        }
        return state
    }
    
    
    func changePswdNetworking(phone: String,pswd: String,confirm: String) -> Observable<BaseModel<EmptyModel>?> {
        return networking.request(.updateAccount(phone: phone, pswd: pswd.et.md5String, confirm: confirm.et.md5String)).mapData(EmptyModel.self)
    }
}
