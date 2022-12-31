//
//  SeacrhMacroViewController.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/3.
//

import UIKit

class SeacrhMacroViewController: LJBaseViewController, UITableViewDataSource, UITableViewDelegate {

    var seacrhMacroTableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    var dataArr: [SearchMacroModel] = []
    
    var macroKey: String = ""
    
    var macroValue: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataArr = SQLManager.queryAllSearchMacro() ?? []
        
        seacrhMacroTableView.reloadData()
        
        UIView.makeToast("左滑条目可删除")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func setupUI(){
        
        view.addSubview(seacrhMacroTableView)
        seacrhMacroTableView.backgroundColor = Colors.mainBackGroundColor
        seacrhMacroTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingVCCell")
        seacrhMacroTableView.dataSource = self
        seacrhMacroTableView.delegate = self
        seacrhMacroTableView.contentInset = UIEdgeInsets(top: WidthScale(20), left: 0, bottom: 0, right: 0)
        seacrhMacroTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        seacrhMacroTableView.reloadData()
        
        createNavbar(navTitle: "搜索宏", leftIsImage: true, leftStr: nil, rightIsImage: false, rightStr: "添加", leftAction: nil, ringhtAction: #selector(addMacroAction))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SettingVCCell")
        
        cell.textLabel?.text = dataArr[indexPath.row].key
        cell.textLabel?.textColor = Colors.whiteTextColor
        cell.backgroundColor = .clear
        cell.detailTextLabel?.textColor = HEXCOLOR(h: 0x949494, alpha: 1.0)
        cell.selectionStyle = .none
        cell.detailTextLabel?.text = dataArr[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = dataArr[indexPath.row]
        
        let alert = UIAlertController(title: model.key, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "修改宏名称", style: .default) { (alert) in
            let alert = LJAlertViewController(withInputPlaceHolder: "请输入宏名称", title: "修改宏名称", confirmTitle: nil, cancelTitle: nil) { (alert) in
                guard let macroKey = alert.inputTF.text else{
                    UIView.makeToast("宏名称不能为空")
                    return
                }
                model.key = macroKey
                
                SQLManager.updateSearchMacro(model)
                
                self.dataArr = SQLManager.queryAllSearchMacro() ?? []
                
                self.seacrhMacroTableView.reloadData()
                
            }
            alert.inputTF.text = model.key
            alert.show()
        }
        let action2 = UIAlertAction(title: "修改宏内容", style: .default) { (alert) in
            let alert = LJAlertViewController(withInputPlaceHolder: "请输入宏内容", title: "修改宏内容", confirmTitle: nil, cancelTitle: nil) { (alert) in
                guard let macroValue = alert.inputTF.text else{
                    UIView.makeToast("宏内容不能为空")
                    return
                }
                model.value = macroValue
                
                SQLManager.updateSearchMacro(model)
                
                self.dataArr = SQLManager.queryAllSearchMacro() ?? []
                
                self.seacrhMacroTableView.reloadData()
                
            }
            alert.inputTF.text = model.value
            alert.show()
        }
        
        let action3 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        UIViewController.getTopViewController().present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) {
            (action, view, completionHandler) in
            if SQLManager.deleteFromMacro(self.dataArr.remove(at: indexPath.row)) > 0{
                Dprint("删除宏成功")
            }else{
                Dprint("删除宏失败")
            }
            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        
        delete.image = UIImage(systemName: "minus.circle.fill")?.withTintColor(.red)
        delete.backgroundColor = tableView.backgroundColor
        //返回所有的事件按钮
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        
        return configuration
    }
    
    @objc func addMacroAction(){
        let alert = LJAlertViewController(withInputPlaceHolder: "请输入宏名称", title: "宏名称", confirmTitle: nil, cancelTitle: nil) { (alert) in
            guard let macroKey = alert.inputTF.text else{
                UIView.makeToast("宏名称不能为空")
                return
            }
            self.macroKey = macroKey
            let alert2 = LJAlertViewController(withInputPlaceHolder: "请输入宏内容", title: "宏内容", confirmTitle: nil, cancelTitle: nil) { (alert) in
                guard let macroValue = alert.inputTF.text else{
                    UIView.makeToast("宏内容不能为空")
                    return
                }
                self.macroValue = macroValue
                let model = SearchMacroModel()
                model.key = self.macroKey
                model.value = self.macroValue
                if SQLManager.insertSearchMacro(model) > 0{
                    UIView.makeToast("添加搜索宏成功")
                }else{
                    UIView.makeToast("添加搜索宏失败")
                }
                
                self.dataArr = SQLManager.queryAllSearchMacro() ?? []
                
                self.seacrhMacroTableView.reloadData()
                
            } canceled: {
                self.macroKey = ""
                self.macroValue = ""
            }
            alert2.show()
        }
        alert.show()
    }

}
