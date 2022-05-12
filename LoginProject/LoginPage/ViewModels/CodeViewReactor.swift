//
//  CodeViewReactor.swift
//  LoveCat
//
//  Created by jingjun on 2022/4/5.
//

import Foundation
import ReactorKit
import BasicProject

final public class CodeViewReactor: Reactor {
    
    public enum Action {
        case getVerificationCode(phone: String)
        case checkCode(phone: String, code: String)
        case checkPhone(phone: String, code: String)
        case bindPhone(phone: String, code: String)
    }
    
    public enum Mutation {
        case setLoading(Bool)
        case getCodeResult(Bool,String)
        case checkCodeResult(Bool,String)
    }
    
    public struct State: StateProtocal {
        public var isLoading: Bool = false
        
        public var isRefreshing: Bool = false
        
        public var endRefreshing: RefreshState?
        
        public var netError: Bool = false
        
        public var page: Int = 0
        
        public var errorMsg: String?
        
        public var getCode: Bool?
        public var checkCode: Bool?
    }
    let networking = NetWorking<LoginApi>()
    public var initialState: State = State.init()
    
    public init() {
        
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getVerificationCode(phone: let phone):
            guard !currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.getVerificationCodeNetworking(phone: phone).map { baseModel -> Mutation in
                if baseModel?.code == 200 {
                    return Mutation.getCodeResult(true, "获取成功")
                }else{
                    return Mutation.getCodeResult(false, baseModel?.message ?? "获取成功")
                }
            }.catchError { error -> Observable<Mutation> in
                return Observable.just(Mutation.getCodeResult(false, "网络错误"))
            }
            return Observable.concat([start,request,end])

        case .checkCode(phone: let phone, code: let code):
            guard !currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.checkCodeNetworking(phone: phone, code: code).map { baseModel -> Mutation in
                if baseModel?.code == 200 {
                    return Mutation.checkCodeResult(true, "校验成功")
                }else{
                    return Mutation.checkCodeResult(false, baseModel?.message ?? "校验失败")
                }
            }.catchError { error -> Observable<Mutation> in
                return Observable.just(Mutation.checkCodeResult(false, "网络错误"))
            }
            return Observable.concat([start,request,end])
            
        case .checkPhone(phone: let phone, code: let code):
            guard !currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.checkPhoneNetworking(phone: phone, code: code).map { baseModel -> Mutation in
                if baseModel?.code == 200 {
                    return Mutation.checkCodeResult(true, "校验成功")
                }else{
                    return Mutation.checkCodeResult(false, baseModel?.message ?? "校验失败")
                }
            }.catchError { error -> Observable<Mutation> in
                return Observable.just(Mutation.checkCodeResult(false, "网络错误"))
            }
            return Observable.concat([start,request,end])
        case .bindPhone(phone: let phone, code: let code):
            guard !currentState.isLoading else {
                return .empty()
            }
            let start = Observable.just(Mutation.setLoading(true))
            let end = Observable.just(Mutation.setLoading(false))
            let request = self.bindPhoneNetworking(phone: phone, code: code).map { baseModel -> Mutation in
                if baseModel?.code == 200 {
                    return Mutation.checkCodeResult(true, "绑定成功")
                }else{
                    return Mutation.checkCodeResult(false, baseModel?.message ?? "绑定失败")
                }
            }.catchError { error -> Observable<Mutation> in
                return Observable.just(Mutation.checkCodeResult(false, "网络错误"))
            }
            return Observable.concat([start,request,end])
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.getCode = nil
        state.checkCode = nil
        switch mutation {
        case .setLoading(let loading):
            state.isLoading = loading
        case .getCodeResult(let result, let msg):
            state.getCode = result
            state.errorMsg = msg
        case .checkCodeResult(let result, let msg):
            state.checkCode = result
            state.errorMsg = msg
        }
        return state
    }
    
    func getVerificationCodeNetworking(phone: String) -> Observable<BaseModel<EmptyModel>?> {
        return networking.request(.getVerificationCode(phone: phone)).mapData(EmptyModel.self)
    }
    
    func checkCodeNetworking(phone: String, code: String) -> Observable<BaseModel<EmptyModel>?> {
        return networking.request(.checkCode(phone: phone, code: code)).mapData(EmptyModel.self)
    }
    
    func checkPhoneNetworking(phone: String, code: String) -> Observable<BaseModel<EmptyModel>?> {
        return networking.request(.checkPhone(phone: phone, code: code)).mapData(EmptyModel.self)
    }
    func bindPhoneNetworking(phone: String, code: String) -> Observable<BaseModel<EmptyModel>?> {
        return networking.request(.bindPhone(phone: phone, code: code)).mapData(EmptyModel.self)
    }
}
