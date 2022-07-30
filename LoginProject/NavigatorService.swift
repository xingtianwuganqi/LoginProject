//
//  NavigatorServiceType.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/16.
//

import RxSwift
import URLNavigator
import ReactorKit
import BasicProject


final class NavigatorService: NavigatorServiceType {
    var navigatorSubject: PublishSubject<NavigatorItemType> = PublishSubject<NavigatorItemType>()
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate let navigator: Navigator
    
    init(navigator: Navigator) {
        self.navigator = navigator
        bind()
    }
    
    fileprivate func bind() {
        self.navigatorSubject.subscribe(onNext: { [weak self](item) in
            guard let `self` = self else { return }
            if let baseItem = item as? BaseLoginNaviItem {
                switch baseItem {
                case .login:
                    let login = LoginViewController.init(reactor: LoginViewReactor.init(), NavigatorServiceType: self)
                    let navi = BaseNavigationController.init(rootViewController: login)
                    navi.modalPresentationStyle = .overFullScreen
                    self.navigator.present(navi)
                }
            }
        }).disposed(by: disposeBag)
        
    }
    
}
