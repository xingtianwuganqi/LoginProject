//
//  CodeViewController.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/10.
//

import UIKit
import ReactorKit
import MBProgressHUD
import BasicProject
import RxSwift
import RxCocoa

public class CodeViewController: BaseViewController,View {
    @IBOutlet weak var backScroll: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codeCheckBtn: UIButton!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var getCodeBtn: UIButton!
    
    @IBOutlet weak var phoneIcon: UIImageView!
    @IBOutlet weak var pswdIcon: UIImageView!
    
    var fromType: CodeFromType?
    var phoneNum: String?
    var timeObserve: DispatchSourceTimer? //定时任务
    
    public typealias Reactor = CodeViewReactor
    
    // cocoapods 本地化需要加
    public override func loadView() {
        Bundle(for: type(of: self)).loadNibNamed("LoginProject.bundle/CodeViewController", owner: self, options: nil)
    }
    
    public init(navi: NavigatorServiceType,from: CodeFromType,phone: String? = nil) {
        super.init(navi: navi)
        self.fromType = from
        self.phoneNum = phone
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if self.fromType == .checkPhone {
            self.navigationItem.title = "校验手机号"
        }else if self.fromType == .bindPhone {
            self.navigationItem.title = "绑定手机号"
        }else{
            self.navigationItem.title = "验证码"
        }
        self.setUI()
        self.reactor = Reactor()
    }

    func setUI() {
        
        self.titleLab.font = UIFont.init(name: "Arial-BoldItalicMT", size: 24)
        self.titleLab.textColor = UIColor.color(.system)
        
        self.codeCheckBtn.backgroundColor = UIColor.color(.system)
        self.codeCheckBtn.setTitleColor(.white, for: .normal)
        
        self.phoneIcon.image = UIImage(named: "icon_login_phone")
        self.pswdIcon.image = UIImage(named: "icon_login_pswd")
        
        if self.fromType == .checkPhone {
            self.codeCheckBtn.setTitle("校验手机号", for: .normal)
        }else if self.fromType == .bindPhone {
            self.codeCheckBtn.setTitle("绑定手机号", for: .normal)
        }else{
            self.codeCheckBtn.setTitle("校验验证码", for: .normal)
        }
        
        self.getCodeBtn.setTitle("获取验证码", for: .normal)
        self.getCodeBtn.setTitleColor(UIColor.color(.system), for: .normal)
        self.getCodeBtn.titleLabel?.font = UIFont.et.font(size: 12)
        self.getCodeBtn.layer.cornerRadius = 5
        self.getCodeBtn.layer.masksToBounds = true
        self.getCodeBtn.layer.borderColor = UIColor.color(.system)?.cgColor
        self.getCodeBtn.layer.borderWidth = 1
        
            
        self.phoneTextField.delegate = self
        self.codeTextField.delegate = self
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(scrollClick))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        // 验证手机号时手机号直接显示
        if fromType == .checkPhone {
            self.phoneTextField.text = self.phoneNum
            self.phoneTextField.isUserInteractionEnabled = false
        }
    }
    
    @objc func agreementBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    
    @objc func scrollClick() {
        self.resignFirst()
    }

    
    @IBAction func checkBtnClick(_ sender: Any) {
        self.phoneTextField.resignFirstResponder()
        self.codeTextField.resignFirstResponder()
        
        guard let phone = self.phoneTextField.text,phone.count > 0 else {
            MBProgressHUD.xy_show("请输入手机号")
            return
        }
        guard phone.et.isChinaMobile else {
            MBProgressHUD.xy_show("请输入正确的手机号")
            return
        }
        guard let code = self.codeTextField.text,code.count > 0 else {
            MBProgressHUD.xy_show("请输入验证码")
            return
        }
        if self.fromType == .checkPhone {
            guard let phoneNum = phoneNum else {
                return
            }
            self.reactor?.action.onNext(.checkPhone(phone: phoneNum, code: code))
        }else if self.fromType == .bindPhone {
            self.reactor?.action.onNext(.bindPhone(phone: phone, code: code))
        }else{
            self.setVerificationCode(phone: phone, code: code)
        }
    }
    
    
    @IBAction func getCodeAction(_ sender: Any) {
        self.phoneTextField.resignFirstResponder()
        self.codeTextField.resignFirstResponder()
        
        guard let phone = self.phoneTextField.text,phone.count > 0 else {
            MBProgressHUD.xy_show("请输入手机号")
            return
        }
        guard phone.et.isChinaMobile else {
            MBProgressHUD.xy_show("请输入正确的手机号")
            return
        }
        self.getVerificationCode(phone: phone)
    }
}
extension CodeViewController {
    public func bind(reactor: Reactor) {
        //观察电话是否为空
        let phoneObserable = phoneTextField.rx.text.share().map { (phone) in
            (phone?.et.isChinaMobile ?? false)
        }
        //验证码是否为空
        let codeObserable = codeTextField.rx.text.share().map {
            ($0?.count ?? 0) > 0
        }

        
        Observable.combineLatest(phoneObserable,codeObserable).subscribe(onNext: { [weak self] (phoneBool , codeBool ) in
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
            $0.getCode
        }.filter {
            $0 != nil
        }
        .subscribe(onNext: { getCode in
            if getCode ?? false {
                self.beginDisTime()
                self.codeTextField.becomeFirstResponder()
            } else {
                return
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.checkCode
        }.filter {
            $0 != nil
        }
        .subscribe(onNext: { [weak self] checkCode in
            guard let `self` = self else { return }
            if checkCode ?? false {
                guard let phone = self.phoneTextField.text?.et.removeHeadAndTailSpacePro else {
                    return
                }
                if self.fromType == .register {
                    // 校验成功，跳转到下一页
                    self.naviService.navigatorSubject.onNext(LoginNavigatorItem.register(phone: phone))
                }else if self.fromType == .findPswd {
                    // 校验成功，跳转修改密码
                    self.naviService.navigatorSubject.onNext(LoginNavigatorItem.changePswd(account: phone))
                }else if self.fromType == .checkPhone {
                    // 校验成功
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }else{
                    // 绑定成功
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                return
            }
        }).disposed(by: disposeBag)
        
        reactor.state.map {
            $0.errorMsg
        }.filter { msg in
            return msg != nil
        }.distinctUntilChanged()
        .subscribe(onNext: { msg in
            if let message = msg {
                MBProgressHUD.xy_show(message)
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
}
extension CodeViewController: UITextFieldDelegate {
    
    func getVerificationCode(phone: String) {
        
        self.reactor?.action.onNext(.getVerificationCode(phone: phone))
        
    }
    
    func setVerificationCode(phone: String,code: String) {
        self.reactor?.action.onNext(.checkCode(phone: phone, code: code))
    }
    
    func beginDisTime() {
        //
        // 倒计时
        self.dispatchTimer(timeInterval: 1, repeatCount: 61) { _, code in

            self.codeBtnNoUse(num: code)
            if code == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.codeBtnCanUse()
                }
            }
        }
               
    }
    
    //MARK:  GCD定时器倒计时
    ///
    /// - Parameters:
    ///   - timeInterval: 间隔时间
    ///   - repeatCount: 重复次数
    ///   - handler: 循环事件,闭包参数: 1.timer 2.剩余执行次数
    func dispatchTimer(timeInterval: Double, repeatCount: Int, handler: @escaping (DispatchSourceTimer?, Int) -> Void) {
        
        if repeatCount <= 0 {
            return
        }
        if timeObserve != nil {
            timeObserve?.cancel()//销毁旧的
        }
        // 初始化DispatchSourceTimer前先销毁旧的，否则会存在多个倒计时
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timeObserve = timer
        var count = repeatCount
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            count -= 1
            DispatchQueue.main.async {
                handler(timer, count)
            }
            if count == 0 {
                timer.cancel()
            }
        }
        timer.resume()
        
    }

    func loginBtnCanUse() {
        self.codeCheckBtn.isEnabled = true
        if self.fromType == .checkPhone {
            self.codeCheckBtn.setTitle("校验手机号", for: .normal)
        }else if self.fromType == .bindPhone {
            self.codeCheckBtn.setTitle("绑定手机号", for: .normal)
        }else{
            self.codeCheckBtn.setTitle("校验验证码", for: .normal)
        }    }
    func loginBtnLoading() {
        self.codeCheckBtn.isEnabled = false
        self.codeCheckBtn.setTitle("正在处理中...", for: .normal)
    }
    
    func loginBtnCanUseNot() {
        self.codeCheckBtn.isEnabled = false
        if self.fromType == .checkPhone {
            self.codeCheckBtn.setTitle("校验手机号", for: .normal)
        }else if self.fromType == .bindPhone {
            self.codeCheckBtn.setTitle("绑定手机号", for: .normal)
        }else{
            self.codeCheckBtn.setTitle("校验验证码", for: .normal)
        }    }
    
    func resignFirst() {
        self.phoneTextField.resignFirstResponder()
        self.codeCheckBtn.resignFirstResponder()
    }
    
    func codeBtnNoUse(num: Int) {
        self.getCodeBtn.setTitle("\(num)s", for: .normal)
        self.getCodeBtn.setTitleColor(UIColor.color(.desc), for: .normal)
        self.getCodeBtn.layer.borderColor = UIColor.color(.desc)?.cgColor
        self.getCodeBtn.isUserInteractionEnabled = false
    }
    
    func codeBtnCanUse(){
        self.getCodeBtn.setTitle("获取验证码", for: .normal)
        self.getCodeBtn.setTitleColor(UIColor.color(.system), for: .normal)
        self.getCodeBtn.titleLabel?.font = UIFont.et.font(size: 12)
        self.getCodeBtn.layer.borderColor = UIColor.color(.system)?.cgColor
        self.getCodeBtn.isUserInteractionEnabled = true

    }

}
