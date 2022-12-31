//
//  SettingNSFWViewController.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/6.
//

import UIKit

class SettingNSFWViewController: LJBaseViewController{
    
    var appKeySettingV: UIView = UIView()
    
    var appKeyTitleL: UILabel = UILabel()
    
    var appKeyL: UILabel = UILabel()
    
    var appKeyIntroTextV: UITextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let appKey =  UserDefaults.standard.value(forKey: Setting.appKey) as? String{
            self.appKeyL.text = appKey
        }else{
            self.appKeyL.text = "未设置AppKey"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupUI(){
        view.backgroundColor = Colors.mainBackGroundColor
        view.addSubview(appKeySettingV)
        appKeySettingV.backgroundColor = .clear
        appKeySettingV.layer.borderWidth = 1
        appKeySettingV.layer.borderColor = HEXCOLOR(h: 0x2F4F4F, alpha: 0.3).cgColor
        appKeySettingV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(appKeySettingVACtion)))
        appKeySettingV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(NavPlusStatusH + WidthScale(20))
            make.left.right.equalToSuperview()
            make.height.equalTo(WidthScale(44))
        }
        
        appKeySettingV.addSubview(appKeyTitleL)
        appKeyTitleL.textColor = Colors.whiteTextColor
        appKeyTitleL.text = "AppKey"
        appKeyTitleL.font = UIFont.systemFont(ofSize: WidthScale(16))
        appKeyTitleL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(WidthScale(20))
            make.centerY.equalToSuperview()
        }
        
        appKeySettingV.addSubview(appKeyL)
        appKeyL.textColor = HEXCOLOR(h: 0x949494, alpha: 1.0)
        appKeyL.text = ""
        appKeyL.font = UIFont.systemFont(ofSize: WidthScale(12))
        appKeyL.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(WidthScale(20))
            make.centerY.equalToSuperview()
        }
        
        
        view.addSubview(appKeyIntroTextV)
        appKeyIntroTextV.isEditable = false
        appKeyIntroTextV.backgroundColor = .clear
        appKeyIntroTextV.textColor = .gray
        appKeyIntroTextV.text = "要获取NSFW级别的图片，需要设置有效的AppKey\n\n AppKey获取方式: 前往www.wallhaven.cc，注册一个属于自己的账号并登录\n\n点击网站右上角的账号头像，选择Setting。\n\n在Setting页面点击左侧菜单栏的Account选项\n\n即可在右侧找到AppKey\n\n 回到本App点击上方AppKey栏将其复制到输入提示框。 \n\n确认有效后即可设置成功，之后即可在筛选设置中控制NSFW的内容的显示。"
        appKeyIntroTextV.font = UIFont.systemFont(ofSize: WidthScale(16))
        appKeyIntroTextV.snp.makeConstraints { (make) in
            make.top.equalTo(appKeySettingV.snp.bottom).offset(WidthScale(20))
            make.left.right.bottom.equalToSuperview().inset(WidthScale(15))
        }
        
        createNavbar(navTitle: "NSFW设置", leftIsImage: true, leftStr: nil, rightIsImage: false, rightStr: nil, leftAction: nil, ringhtAction: nil)
    }
    
    @objc func appKeySettingVACtion(){

        let alert = LJAlertViewController(withInputPlaceHolder: "请输入AppKey", title: "输入AppKey", confirmTitle: nil, cancelTitle: nil) { (alert) in
            
            UserDefaults.standard.setValue(alert.inputTF.text, forKey: Setting.appKey)
            
            UIView.startLoading()
            
            WallPaperInfoManager.shared.searchWallpaper(ByTag: "", page: 1, isAuthentic: true) { (modelArr, error) in
                UIView.stopLoading()
                if modelArr != nil{
                    UIView.makeToast("AppKey设置成功")
                    if let appKey =  UserDefaults.standard.value(forKey: Setting.appKey) as? String{
                        self.appKeyL.text = appKey
                    }
                }else{
                    UIView.makeToast("AppKey设置失败")
                    UserDefaults.standard.setValue(nil, forKey: Setting.appKey)
                    self.appKeyL.text = "未设置AppKey"
                }
                
            }
            
            
        }
        
        alert.show()
    }


}
