//
//  ViewController.swift
//  LoginProject
//
//  Created by jingjun on 2022/5/11.
//

import UIKit
import BasicProject

class TestViewController: BaseViewController {
    lazy var tableView : UITableView = {
        let backview = UITableView.init(frame: .zero, style: .grouped)
        backview.backgroundColor = .white
        backview.showsVerticalScrollIndicator = false
        backview.showsHorizontalScrollIndicator = false
        backview.estimatedRowHeight = 0
        backview.estimatedSectionFooterHeight = 0
        backview.estimatedSectionHeaderHeight = 0
        backview.separatorStyle = .none
        backview.delegate = self
        backview.dataSource = self
        return backview
    }()
    
    override init(navi: NavigatorServiceType) {
        super.init(navi: navi)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let datas = ["登录","验证手机号"]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "commentcell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "commentcell")
        }
        cell?.textLabel?.text = datas[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = datas[indexPath.row]
        if value == "登录" {
            self.naviService.navigatorSubject.onNext(BaseLoginNaviItem.login)
        }
    }
}

