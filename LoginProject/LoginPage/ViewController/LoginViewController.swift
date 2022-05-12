//
//  LoginViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/8.
//

import UIKit
import ReactorKit
import MBProgressHUD
import BasicProject
import RxSwift
import RxCocoa

public class LoginViewController: BaseViewController,View {
    
    @IBOutlet weak var backScroll: UIScrollView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pswdTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgetBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var agreementBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    public typealias Reactor = LoginViewReactor
    
    lazy var agreementContent: UILabel = {
        let content = UILabel()
        content.font = UIFont.et.font(.regular, size: 12)
        content.textColor = UIColor.color(.content)
        return content
    }()
    
    lazy var protocalContent: UILabel = {
        let content = UILabel()
        content.font = UIFont.et.font(.regular, size: 12)
        content.textColor = UIColor.color(.content)
        return content
    }()
    
    lazy var backBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "icon_a_back"), for: .normal)
        button.addTarget(self, action: #selector(popAction), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }()

    var newReactor: LoginViewReactor
    public init(reactor: Reactor,
         NavigatorServiceType: NavigatorServiceType) {
        self.newReactor = reactor
        super.init(navi: NavigatorServiceType)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "登录"
        self.setUI()
        self.addGesture()
        self.setAgreement()
        self.reactor = newReactor
    }

    func setUI() {
        
        self.backScroll.delaysContentTouches = true
        self.backScroll.canCancelContentTouches = false
        
        self.titleLab.font = UIFont.init(name: "Arial-BoldItalicMT", size: 24)
        self.titleLab.textColor = UIColor.color(.system)
        
        self.loginBtn.setTitle("登录", for: .normal)
        self.loginBtn.backgroundColor = UIColor.color(.system)
        self.loginBtn.setTitleColor(.white, for: .normal)
        
        self.registerBtn.setTitle("忘记密码", for: .normal)
        self.registerBtn.setTitleColor(UIColor.color(.system), for: .normal)
        
        self.registerBtn.setTitle("新用户注册", for: .normal)
        self.registerBtn.setTitleColor(UIColor.color(.system), for: .normal)
        
        self.forgetBtn.setTitle("忘记密码？", for: .normal)
        self.forgetBtn.setTitleColor(UIColor.color(.system), for: .normal)
        
        self.pswdTextField.isSecureTextEntry = true
        if #available(iOS 11.0, *) {
            self.phoneTextField.textContentType = .username
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            self.pswdTextField.textContentType = .password
        } else {
            // Fallback on earlier versions
        }

        
        self.agreementBtn.isSelected = true
        self.agreementBtn.addTarget(self, action: #selector(agreementBtnClick(btn: )), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: self.backBtn)
        
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(scrollClick))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func agreementBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    
    @objc func scrollClick() {
        self.resignFirst()
    }
    
    func setAgreement() {
            
        let content = "阅读并同意"
        let heightContent = "用户协议"
        let attrbute = NSMutableAttributedString()
        attrbute.append(NSAttributedString(string: content, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#292929")!, NSAttributedString.Key.font: UIFont.et.font(size: 12)]))
      
        attrbute.append(NSAttributedString(string: heightContent, attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.system)!, NSAttributedString.Key.font: UIFont.et.font(size: 12)]))

        self.agreementContent.attributedText = attrbute
        stackView.addArrangedSubview(self.agreementContent)
        
        let proAtt = NSMutableAttributedString.init(string: "、隐私政策", attributes: [NSAttributedString.Key.foregroundColor: UIColor.color(.system)!, NSAttributedString.Key.font: UIFont.et.font(size: 12)])
        
        self.protocalContent.attributedText = proAtt
        stackView.addArrangedSubview(self.protocalContent)

        
        self.agreementContent.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(agreementContentClick))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        agreementContent.addGestureRecognizer(tap)
        
        self.protocalContent.isUserInteractionEnabled = true
        let proTap = UITapGestureRecognizer.init(target: self, action: #selector(protocalContentClick))
        proTap.numberOfTouchesRequired = 1
        proTap.numberOfTapsRequired = 1
        protocalContent.addGestureRecognizer(proTap)

    }
    
    @objc func agreementContentClick() {
        self.naviService.navigatorSubject.onNext(LoginNavigatorItem.webProtocalPage(url: baseUrlConfig + UserProtocal.userAgreen.rawValue))
    }
    
    @objc func protocalContentClick() {
        self.naviService.navigatorSubject.onNext(LoginNavigatorItem.webProtocalPage(url: baseUrlConfig + UserProtocal.pravicy.rawValue))
    }
    
    func addGesture() {
        // 添加侧滑手势
        let edgePanGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGestureAction(gesture:)))
        edgePanGes.edges = UIRectEdge.left
        self.view.addGestureRecognizer(edgePanGes)
    }

    @objc private func edgePanGestureAction(gesture: UIScreenEdgePanGestureRecognizer) {
        
        let point =  gesture.translation(in: self.view)
        switch gesture.state {
        case .began:
            self.navigationController?.view.transform = CGAffineTransform(translationX: point.x, y: 0)
        case .changed:
            self.navigationController?.view.transform = CGAffineTransform(translationX: point.x >= 0 ? point.x : 0, y: 0)
        default:
            if point.x > 50 {
                UIView.animate(withDuration: 0.35, animations: {
                    self.navigationController?.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width, y: 0)
                }) { (isFinished) in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
            else {
                UIView.animate(withDuration: 0.35) {
                    self.navigationController?.view.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            }
        }
    }
    
    @IBAction func registerBtnClickAction(_ sender: Any) {
        self.naviService.navigatorSubject.onNext(LoginNavigatorItem.checkCode(.register, nil))
    }
    
    @IBAction func forgetBtnClick(_ sender: Any) {
        self.naviService.navigatorSubject.onNext(LoginNavigatorItem.checkCode(.findPswd, nil))
    }
    
    @IBAction func loginBtnClick(_ sender: Any) {
        guard self.agreementBtn.isSelected else {
            MBProgressHUD.xy_show("请勾选用户协议")
            return
        }
        
        guard let account = self.phoneTextField.text,account.count > 0 else {
            MBProgressHUD.xy_show("请输入账号")
            return
        }
        guard account.et.isChinaMobile else {
            MBProgressHUD.xy_show("请输入有效账号")
            return
        }
        guard let pswd = self.pswdTextField.text,pswd.et.isValidPassword else {
            MBProgressHUD.xy_show("请输入6位或6位以上密码")
            return
        }
                
        self.reactor?.action.onNext(.loginAction(phone: account, pswd: pswd))
    }
    
    @objc func popAction() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        // 测试代码
//        self.navigationController?.dismiss(animated: true, completion: {
//            let jpush = JpushManager.init()
//            jpush.bindingDeviceAlias(alias: 1)
//        })
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirst()
    }
    @IBAction func changeBtnClick(_ sender: Any) {
        let button = sender as! UIButton
        guard let pswd = self.pswdTextField.text,pswd.count > 0 else {
            return
        }
        button.isSelected = !button.isSelected
        if button.isSelected {
            pswdTextField.isSecureTextEntry = false
        }else {
            pswdTextField.isSecureTextEntry = true
        }
    }
    
    deinit {
        printLog("login deinit")
    }
    
}
extension LoginViewController {
    public func bind(reactor: LoginViewReactor) {
        //观察电话是否为空
        let phoneObserable = phoneTextField.rx.text.share().map { (phone) in
            (phone?.et.isChinaMobile ?? false)
        }
        //密码是否为空
        let pswdObserable = pswdTextField.rx.text.share().map {
            $0?.et.isValidPassword ?? false
        }
        
        Observable.combineLatest(phoneObserable,pswdObserable).subscribe(onNext: { [weak self] (phoneBool , pswdBool) in
            guard let `self` = self else {
                return
            }
            
            guard phoneBool && pswdBool else {
                
                self.loginBtnCanUseNot()
                return
            }
            
            self.loginBtnCanUse()
            
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.isLoading
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self](isLoading) in
            guard let `self` = self else { return }
            if isLoading {
                self.loginBtnLoading()
            }else{
                self.loginBtnCanUse()
            }
        }).disposed(by: disposeBag)
        
        
        reactor.state.map {
            $0.isLogin
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self](isLogin) in
            guard let `self` = self else { return }
            if isLogin,let userModel = self.reactor?.currentState.userInfo {
//                UserManager.shared.upLoadUserInfo(userModel)
//                self.navigationController?.dismiss(animated: true, completion: {
//                    UserManager.shared.loginSuccess.onNext(Void())
//                    // 设置推送别名
//                    let jpush = JpushManager.init()
//                    jpush.bindingDeviceAlias(alias: userModel.id ?? 1)
//                })
                UserManager.shared.loginSuccessCallBack?((1,userModel))

            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.msg
        }.filter { msg in
            return msg != nil
        }.subscribe(onNext: { msg in
            if let message = msg {
                MBProgressHUD.xy_show(message)
            }
        }).disposed(by: disposeBag)
        

    }
}
extension LoginViewController {
    func loginBtnCanUse() {
        self.loginBtn.isEnabled = true
        self.loginBtn.setTitle("登录", for: .normal)
    }
    func loginBtnLoading() {
        self.loginBtn.isEnabled = false
        self.loginBtn.setTitle("正在处理中...", for: .normal)
    }
    
    func loginBtnCanUseNot() {
        self.loginBtn.isEnabled = false
        self.loginBtn.setTitle("登录", for: .normal)
    }
    
    func resignFirst() {
        self.phoneTextField.resignFirstResponder()
        self.pswdTextField.resignFirstResponder()
    }

}

