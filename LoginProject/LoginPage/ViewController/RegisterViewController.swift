//
//  RegisterViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/10.
//

import UIKit
import ReactorKit
import MBProgressHUD
import RxSwift
import RxCocoa
import BasicProject

public class RegisterViewController: BaseViewController,View {
    @IBOutlet weak var backScroll: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pswdTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var agreeMentBtn: UIButton!
    @IBOutlet weak var pswdEyeBtn: UIButton!
    @IBOutlet weak var confiEyeBtn: UIButton!
    @IBOutlet weak var phoneIcon: UIImageView!
    @IBOutlet weak var pswdIcon: UIImageView!
    @IBOutlet weak var confiIcon: UIImageView!
    
    var phone: String
    var pswdS1: String?
    var confrimS2: String?
    
    public typealias Reactor = RegisterViewReactor
    
    // cocoapods 本地化需要加
    public override func loadView() {
        Bundle(for: type(of: self)).loadNibNamed("LoginProject.bundle/RegisterViewController", owner: self, options: nil)
    }
    
    
    public init(navi: NavigatorServiceType, phone: String) {
        self.phone = phone
        super.init(navi: navi)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "注册"
        self.setUI()
        self.setAgreement()
        self.reactor = Reactor()
    }

    func setUI() {
        
        self.titleLab.font = UIFont.init(name: "Arial-BoldItalicMT", size: 24)
        self.titleLab.textColor = UIColor.color(.system)
        self.titleLab.text = AppIdentifier.rawValue
        
        self.phoneIcon.image = LGResourceBundle.getImage("icon_login_phone")
        self.pswdIcon.image = LGResourceBundle.getImage("icon_login_pswd")
        self.confiIcon.image = LGResourceBundle.getImage("icon_login_pswd")

        
        self.pswdEyeBtn.setImage(LGResourceBundle.getImage("icon_eye_o"), for: .normal)
        self.pswdEyeBtn.setImage(LGResourceBundle.getImage("icon_eye_b"), for: .selected)
        
        self.confiEyeBtn.setImage(LGResourceBundle.getImage("icon_eye_o"), for: .normal)
        self.confiEyeBtn.setImage(LGResourceBundle.getImage("icon_eye_b"), for: .selected)
        
        self.agreeMentBtn.setImage(LGResourceBundle.getImage("icon_lo_sele"), for: .selected)
        self.agreeMentBtn.setImage(LGResourceBundle.getImage("icon_lo_unse"), for: .normal)
        
        self.loginBtn.setTitle("注册并登录", for: .normal)
        self.loginBtn.backgroundColor = UIColor.color(.system)
        self.loginBtn.setTitleColor(.white, for: .normal)
        
        self.pswdTextField.isSecureTextEntry = false
        self.confirmTextField.isSecureTextEntry = false
    
        self.phoneTextField.delegate = self
        self.pswdTextField.delegate = self
        self.confirmTextField.delegate = self
        
        self.agreeMentBtn.isSelected = true

        self.agreeMentBtn.addTarget(self, action: #selector(agreementBtnClick(btn: )), for: .touchUpInside)

        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(scrollClick))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        // 直接显示手机号且不可更改
        self.phoneTextField.text = self.phone
        self.phoneTextField.isEnabled = false
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

    
    @IBAction func loginBtnClick(_ sender: Any) {
        self.pswdTextField.resignFirstResponder()
        self.confirmTextField.resignFirstResponder()
        
        guard self.agreeMentBtn.isSelected else {
            self.view.xy_show("请勾选用户协议")
            return
        }
        guard let account = self.phoneTextField.text,account.count > 0 else {
            self.view.xy_show("请输入账号")
            return
        }
        guard account.et.isChinaMobile else {
            self.view.xy_show("请输入有效账号")
            return
        }
        guard let pswd = self.pswdS1,pswd.et.isValidPassword else {
            self.view.xy_show("请输入6位或6位以上密码")
            return
        }
        guard let confrim = self.confrimS2,confrim.et.isValidPassword else {
            self.view.xy_show("请输入6位或6位以上密码")
            return
        }
        guard pswd == confrim else {
            self.view.xy_show("两次输入密码不相同")
            return
        }
        
        self.reactor?.action.onNext(.loginAndRegister(phone: account, pswd: pswd, confrim: confrim))
    }
    @IBAction func pswdShowNum(_ sender: Any) {
        pswdTextField.resignFirstResponder()
        let button = sender as! UIButton
        guard let pswd = self.pswdS1,pswd.count > 0 else {
            return
        }
        button.isSelected = !button.isSelected
        if button.isSelected {
            pswdTextField.text = pswd
        }else {
            let len = pswd.count
            let n = ""
            let symbol1 = n.padding(toLength: len, withPad: "●", startingAt: 0)
            pswdTextField.text = symbol1
        }
    }
    @IBAction func confrimShowNum(_ sender: Any) {
        confirmTextField.resignFirstResponder()
        let button = sender as! UIButton
        guard let confrimPswd = self.confrimS2,confrimPswd.count > 0 else {
            return
        }
        button.isSelected = !button.isSelected
        if button.isSelected {
            confirmTextField.text = confrimPswd
        }else {
            let len = confrimPswd.count
            let n = ""
            let symbol1 = n.padding(toLength: len, withPad: "●", startingAt: 0)
            confirmTextField.text = symbol1
        }
    }
}
extension RegisterViewController {
    public func bind(reactor: Reactor) {
        //观察电话是否为空
        let phoneObserable = phoneTextField.rx.text.share().map { (phone) in
            (phone?.et.isChinaMobile ?? false)
        }
        //密码是否为空
        let pswdObserable = pswdTextField.rx.text.share().map {
            $0?.et.isValidPassword ?? false
        }
        
        let confirmObserable = confirmTextField.rx.text.share().map {
            $0?.et.isValidPassword ?? false
        }
        
        Observable.combineLatest(phoneObserable,pswdObserable,confirmObserable).subscribe(onNext: { [weak self] (phoneBool , pswdBool, confirmBool) in
            guard let `self` = self else {
                return
            }
            
            guard phoneBool && pswdBool && confirmBool else {
                
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
////                self.navigationController?.dismiss(animated: true, completion: nil)
//                // 跳转到设置
//                self.naviService.navigatorSubject.onNext(NavigatorItem.userEdit(fromType: 1))
//                // 发出通知
//                UserManager.shared.loginSuccess.onNext(Void())
//                // 设置推送别名
//                let jpush = JpushManager.init()
//                jpush.bindingDeviceAlias(alias: userModel.id ?? 1)
                UserManager.shared.loginSuccessCallBack?((2,userModel))
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.msg
        }.filter { msg in
            return msg != nil
        }.subscribe(onNext: { msg in
            if let message = msg {
                self.view.xy_show(message)
            }
        }).disposed(by: disposeBag)
        
    }
}
extension RegisterViewController: UITextFieldDelegate {
    
    //每次開始輸入就將TextField初始化，並設定isSecureTextEntry = true啟用隱碼功能。
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (textField == pswdTextField) {
            pswdTextField.text = ""
            pswdTextField.becomeFirstResponder()
            pswdTextField.isSecureTextEntry = true
        }
        
        if (textField == confirmTextField) {
            confirmTextField.text = ""
            confirmTextField.becomeFirstResponder()
            confirmTextField.isSecureTextEntry = true
        }
    }
    
    //每次結束輸入就將輸入值存到變數中以供送電文用，TextField欄位則設定isSecureTextEntry = false關閉隱碼功能，但是以"●"取代輸入值。
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        var len = 0;
        let n = ""
        
        if (textField == pswdTextField){
            pswdTextField.isSecureTextEntry = false
            len = pswdTextField.text!.count
            
            if (len == 0){
                pswdTextField.text = ""
            }else{
                pswdS1 = pswdTextField.text!
                let symbol1 = n.padding(toLength: len, withPad: "●", startingAt: 0)
                pswdTextField.text = symbol1
            }
        }
        
        if (textField == confirmTextField){
            confirmTextField.isSecureTextEntry = false
            len = confirmTextField.text!.count
            
            if (len == 0){
                confirmTextField.text = ""
            }else{
                confrimS2 = confirmTextField.text!
                let symbol2 = n.padding(toLength: len, withPad: "●", startingAt: 0)
                confirmTextField.text = symbol2
            }
        }
    }
    
    func loginBtnCanUse() {
        self.loginBtn.isEnabled = true
        self.loginBtn.setTitle("注册并登录", for: .normal)
    }
    func loginBtnLoading() {
        self.loginBtn.isEnabled = false
        self.loginBtn.setTitle("正在处理中...", for: .normal)
    }
    
    func loginBtnCanUseNot() {
        self.loginBtn.isEnabled = false
        self.loginBtn.setTitle("注册并登录", for: .normal)
    }
    
    func resignFirst() {
        self.pswdTextField.resignFirstResponder()
        self.confirmTextField.resignFirstResponder()
    }

}
