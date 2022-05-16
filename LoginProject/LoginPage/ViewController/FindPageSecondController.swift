//
//  FindPageSecondController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/10.
//

import UIKit
import RxSwift
import MBProgressHUD
import BasicProject
import ReactorKit
public class FindPageSecondController: BaseViewController,View {
    
    
    @IBOutlet weak var backScroll: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var pswdTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var pswdIcon: UIImageView!
    @IBOutlet weak var confiIcon: UIImageView!
    
    @IBOutlet weak var pswdEyeBtn: UIButton!
    @IBOutlet weak var confiEyeBtn: UIButton!
    var pswdS1: String?
    var confrimS2: String?
    
    public typealias Reactor = FindPswdChangeReactor
    fileprivate var account: String
    
    
    // cocoapods 本地化需要加
    public override func loadView() {
        Bundle(for: type(of: self)).loadNibNamed("LoginProject.bundle/FindPageSecondController", owner: self, options: nil)
    }
    
    public init(account: String,
         naviService: NavigatorServiceType) {
        self.account = account
        super.init(navi: naviService)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "找回密码"
        self.setUI()
        self.reactor = FindPswdChangeReactor.init(account: self.account)
    }
    
    func setUI() {
        
        self.titleLab.font = UIFont.init(name: "Arial-BoldItalicMT", size: 24)
        self.titleLab.textColor = UIColor.color(.system)
        
        self.pswdIcon.image = UIImage(named: "icon_login_pswd")
        self.confiIcon.image = UIImage(named: "icon_login_pswd")
        
        self.pswdEyeBtn.setImage(UIImage(named: "icon_eye_o"), for: .normal)
        self.pswdEyeBtn.setImage(UIImage(named: "icon_eye_b"), for: .selected)
        
        self.confiEyeBtn.setImage(UIImage(named: "icon_eye_o"), for: .normal)
        self.confiEyeBtn.setImage(UIImage(named: "icon_eye_b"), for: .selected)
        
        self.loginBtn.setTitle("确定", for: .normal)
        self.loginBtn.backgroundColor = UIColor.color(.system)
        self.loginBtn.setTitleColor(.white, for: .normal)
        
        self.pswdTextField.isSecureTextEntry = true
        self.confirmTextField.isSecureTextEntry = true
        
        self.pswdTextField.delegate = self
        self.confirmTextField.delegate = self

        
        backScroll.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(scrollClick))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        backScroll.addGestureRecognizer(tap)
    }
    
    @objc func scrollClick() {
        self.resignFirst()
    }
    
    func resignFirst() {
        self.confirmTextField.resignFirstResponder()
        self.pswdTextField.resignFirstResponder()
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
    
    @IBAction func confirmShowNum(_ sender: Any) {
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
    
    @IBAction func confirmBtnClick(_ sender: Any) {
        self.resignFirst()
        guard let pswd = self.pswdS1,pswd.et.isValidPassword else {
            MBProgressHUD.xy_show("请输入6位或6位以上密码")
            return
        }
        guard let confrim = self.confrimS2,confrim.et.isValidPassword else {
            MBProgressHUD.xy_show("请再次输入密码")
            return
        }
        guard pswd == confrim else {
            MBProgressHUD.xy_show("两次输入密码不相同")
            return
        }
        
        self.reactor?.action.onNext(.changePswd(phone: account, pswd: pswd, confrim: confrim))
    }
    
}

extension FindPageSecondController: UITextFieldDelegate {
    
    public func bind(reactor: FindPswdChangeReactor) {
        //观察电话是否为空
        //密码是否为空
        let pswdObserable = pswdTextField.rx.text.share().map {
            $0?.et.isValidPassword ?? false
        }
        
        let confirmObserable = confirmTextField.rx.text.share().map {
            $0?.et.isValidPassword ?? false
        }
        
        
        Observable.combineLatest(pswdObserable,confirmObserable).subscribe(onNext: { [weak self] (phoneBool , codeBool ) in
            guard let `self` = self else {
                return
            }
            
            guard phoneBool && codeBool else {
                self.loginBtnCanUseNot()
                return
            }
            
            self.loginBtnCanUse()
            
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.changeResult
        }.filter {
            $0 != nil
        }
        .subscribe(onNext: { result in
            if result == true {
                MBProgressHUD.xy_show("修改成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }else{
                MBProgressHUD.xy_show(reactor.currentState.errorMsg ?? "修改失败")
            }
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
    }
    
    
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
    
}
extension FindPageSecondController {
    func loginBtnCanUse() {
        self.loginBtn.isEnabled = true
        self.loginBtn.setTitle("确定", for: .normal)
    }
    func loginBtnLoading() {
        self.loginBtn.isEnabled = false
        self.loginBtn.setTitle("正在处理中...", for: .normal)
    }
    
    func loginBtnCanUseNot() {
        self.loginBtn.isEnabled = false
        self.loginBtn.setTitle("确定", for: .normal)
    }
    
}
