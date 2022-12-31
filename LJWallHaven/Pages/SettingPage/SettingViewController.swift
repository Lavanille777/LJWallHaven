//
//  SettingViewController.swift
//  LJWallHaven
//  设置页
//  Created by 唐星宇 on 2021/3/2.
//

import UIKit
import SDWebImage
import MessageUI
import StoreKit
import YYKit

class SettingViewController: LJBaseViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate{
    
    var settingTableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    var titleArr: [[String]] = [["历史浏览","收藏夹","搜索宏"],["图片浏览页自动显示工具栏", "仅WiFi下自动加载原图", "打开滚动时的动画", "设置最大缓存", "清除所有缓存","设置NSFW内容显示"],["去App Store写评价","通过邮件向作者反馈"]]
    
    var autoDisplayToolViewSwitch: UISwitch = UISwitch()
    var autoLoadSwitch: UISwitch = UISwitch()
    var scrollAnimationSwitch: UISwitch = UISwitch()
    
    var maxDiskSize: String = "1024MB"{
        didSet{
            DispatchQueue.main.async {
                self.settingTableView.reloadData()
            }
        }
    }
    
    var totalDiskSize: String = "0MB"{
        didSet{
            DispatchQueue.main.async {
                self.settingTableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoLoadSwitch.isOn = Setting.notAutoLoad
        
        autoDisplayToolViewSwitch.isOn = Setting.autoDisplayToolView
        
        scrollAnimationSwitch.isOn = Setting.scrollAnimationEnable

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async {
            self.maxDiskSize = String(format: "%.1lfMB", Double(YYImageCache.shared().diskCache.costLimit) / 1024.0 / 1024.0)
            self.totalDiskSize = String(format: "%.1lfMB", Double(YYImageCache.shared().diskCache.totalCost()) / 1024.0 / 1024.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupUI(){
        
        view.addSubview(settingTableView)
        settingTableView.backgroundColor = Colors.mainBackGroundColor
        settingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingVCCell")
        settingTableView.dataSource = self
        settingTableView.delegate = self
//        settingTableView.bounces = false
        settingTableView.contentInset = UIEdgeInsets(top: WidthScale(20), left: 0, bottom: 0, right: 0)
        settingTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        settingTableView.reloadData()
        
        autoLoadSwitch.addTarget(self, action: #selector(autoLoadSwitchAction), for: .valueChanged)
        scrollAnimationSwitch.addTarget(self, action: #selector(scrollAnimationSwitchAction), for: .valueChanged)
        autoDisplayToolViewSwitch.addTarget(self, action: #selector(autoDisplayToolViewSwitchAction), for: .valueChanged)
        
        createNavbar(navTitle: "更多", leftIsImage: false, leftStr: nil, rightIsImage: false, rightStr: nil, leftAction: nil, ringhtAction: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SettingVCCell")
        
        cell.textLabel?.text = titleArr[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = Colors.whiteTextColor
        cell.backgroundColor = .clear
        cell.detailTextLabel?.textColor = HEXCOLOR(h: 0x949494, alpha: 1.0)
        switch titleArr[indexPath.section][indexPath.row] {
        case "设置最大缓存":
            cell.detailTextLabel?.text = maxDiskSize
        case "清除所有缓存":
            cell.detailTextLabel?.text = "已占用\(totalDiskSize)"
        case "图片浏览页自动显示工具栏":
            cell.accessoryView = autoDisplayToolViewSwitch
        case "仅WiFi下自动加载原图":
            cell.accessoryView = autoLoadSwitch
        case "打开滚动时的动画":
            cell.accessoryView = scrollAnimationSwitch
        case "设置皮肤":
            cell.detailTextLabel?.text = ""
        default:
            cell.detailTextLabel?.text = ""
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.cellForRow(at: indexPath)?.textLabel?.text {
        case "历史浏览":
            self.navigationController?.pushViewController(BrowseHistoryViewController(withType: 0), animated: true)
        case "收藏夹":
            self.navigationController?.pushViewController(BrowseHistoryViewController(withType: 1), animated: true)
        case "搜索宏":
            self.navigationController?.pushViewController(SeacrhMacroViewController(), animated: true)
        case "设置最大缓存":
            let alert = LJAlertViewController(withInputPlaceHolder: "请输入大于0的最大缓存值", title: "设置最大缓存", confirmTitle: "确定", cancelTitle: "取消") { (alert) in
                
                if var size = UInt(alert.inputTF.text ?? "0"){
                    if size == 0{
                       size = 1024
                    }
                    YYImageCache.shared().diskCache.costLimit = size * 1024 * 1024
                }
                DispatchQueue.global().async {
                    self.maxDiskSize = String(format: "%.1lfMB", Double(YYImageCache.shared().diskCache.costLimit) / 1024.0 / 1024.0)
                    self.totalDiskSize = String(format: "%.1lfMB", Double(YYImageCache.shared().diskCache.totalCost()) / 1024.0 / 1024.0)
                }
                UserDefaults.standard.setValue(YYImageCache.shared().diskCache.costLimit, forKey: Setting.diskSize, synchronizeToCloud: true)
            }
            alert.inputTF.keyboardType = .numberPad
            alert.show()
        case "清除所有缓存":
            let alert = LJAlertViewController(withTitle: "确定要清除所有缓存吗", alert: "将释放\(totalDiskSize)空间", confirmTitle: nil, cancelTitle: nil) { (alert) in
                YYImageCache.shared().diskCache.removeAllObjects {
                    UIView.makeToast("已清除所有缓存")
                    DispatchQueue.global().async {
                        self.maxDiskSize = String(format: "%.1lfMB", Double(YYImageCache.shared().diskCache.costLimit) / 1024.0 / 1024.0)
                        self.totalDiskSize = String(format: "%.1lfMB", Double(YYImageCache.shared().diskCache.totalCost()) / 1024.0 / 1024.0)
                    }
                }
            }
            alert.show()
        case "设置NSFW内容显示":
            UIViewController.getCurrentViewCtrl().navigationController?.pushViewController(SettingNSFWViewController(), animated: true)
            break
        case "设置皮肤":
            let alert = UIAlertController(title: "设置皮肤", message: nil, preferredStyle: .actionSheet)
            
            let action1 = UIAlertAction(title: "浅色", style: .default) { (alert) in
                UserDefaults.standard.setValue("浅色", forKey: Setting.skin, synchronizeToCloud: true)
            }
            
            let action2 = UIAlertAction(title: "深色", style: .default) { (alert) in
                UserDefaults.standard.setValue("深色", forKey: Setting.skin, synchronizeToCloud: true)
            }
            
            let action3 = UIAlertAction(title: "跟随系统", style: .default) { (alert) in
                UserDefaults.standard.setValue("跟随系统", forKey: Setting.skin, synchronizeToCloud: true)
            }
            
            let action4 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(action1)
            alert.addAction(action2)
            alert.addAction(action3)
            alert.addAction(action4)
            
            UIViewController.getTopViewController().present(alert, animated: true, completion: nil)
            
        case "为App评分":
            SKStoreReviewController.requestReview()
        case "去App Store写评价":
            let storeVC = SKStoreProductViewController()
            storeVC.delegate = self
            self.present(storeVC, animated: true, completion: nil)
            storeVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: AppID], completionBlock: {
                (result, error) in
                if result && error == nil {
                    print("链接加载成功！！！")
                    
                } else {
                    print(error as Any)
                }
            })
        case "通过邮件向作者反馈":
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setSubject("Wallhaven应用反馈")
            var systemInfo = utsname()
            uname(&systemInfo)
            let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
                return String(cString: ptr)
            }
            mailVC.setMessageBody("尽管吐槽别客气，如果是Bug，请尽量详细的描述你遇到的问题。<br><br><br>应用版本：\(Setting.app_version)<br>系统版本：\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)<br>设备型号：\(platform)", isHTML: true)
            mailVC.setToRecipients(["lavanille777@icloud.com"])
            if MFMailComposeViewController.canSendMail() {
                present(mailVC, animated: true, completion: nil)
            } else {
                UIView.makeToast("你还没有在设备上设置发件的邮箱账户")
            }
        case "Image测试":
//            let vc = LJBaseViewController()
//            let yyimgV = YYAnimatedImageView(image: YYImage(named: "become_couple_banner_ani"))
//            let path = Bundle.main.path(forResource: "become_couple_banner_ani", ofType: "webp")!
//            let data = NSData.init(contentsOfFile: path)
//            let image = SDImageWebPCoder.shared.decodedImage(with: data as Data, options: nil)
//            let sdimgV = SDAnimatedImageView(image: <#T##UIImage?#>)
        break
        default:
            break
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let error = error{
            Dprint(error)
        }
        
        switch result {
        case .sent:
            UIView.makeToast("发送成功")
        case .failed:
            UIView.makeToast("发送失败")
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func autoDisplayToolViewSwitchAction(){
        UserDefaults.standard.setValue(autoDisplayToolViewSwitch.isOn, forKey: Setting.autoDisplayToolViewKey, synchronizeToCloud: true)
        Setting.autoDisplayToolView = autoDisplayToolViewSwitch.isOn
    }
    
    @objc func autoLoadSwitchAction(){
        UserDefaults.standard.setValue(autoLoadSwitch.isOn, forKey: Setting.autoLoadingOriginalSizeImage, synchronizeToCloud: true)
        Setting.notAutoLoad = autoLoadSwitch.isOn
    }
    
    @objc func scrollAnimationSwitchAction(){
        UserDefaults.standard.setValue(scrollAnimationSwitch.isOn, forKey: Setting.scrollAnimationSwitchKey, synchronizeToCloud: true)
        Setting.scrollAnimationEnable = scrollAnimationSwitch.isOn
    }

}
