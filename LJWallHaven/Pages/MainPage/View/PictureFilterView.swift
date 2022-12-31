//
//  PictureFilterView.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/4.
//

import UIKit

class PictureFilterView: UIView {
    
    var blurV: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    
    var categoriesL: UILabel = UILabel()
    
    var categoriesBtnArr: [UIButton] = [UIButton(), UIButton(), UIButton()]
    
    var sortingL: UILabel = UILabel()
    
    var sortingBtnArr: [UIButton] = [UIButton(), UIButton(), UIButton(), UIButton()]
    
    var orderL: UILabel = UILabel()

    var orderBtnArr: [UIButton] = [UIButton(), UIButton()]
    
    var purityL: UILabel = UILabel()
    
    var purityBtnArr: [UIButton] = [UIButton(), UIButton(), UIButton()]
    
    var searchBtn: UIButton = UIButton()
    
    var colorL: UILabel = UILabel()
    
    var colorBtnArr: [UIButton] = [UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton()]
    
    var buttonSize: CGSize = CGSize(width: WidthScale(80), height: WidthScale(30))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if UserDefaults.standard.value(forKey: SearchFilterSetting.categoriesKey) == nil{
            UserDefaults.standard.setValue("111", forKey: SearchFilterSetting.categoriesKey, synchronizeToCloud: true)
        }
        
        if UserDefaults.standard.value(forKey: SearchFilterSetting.sortingKey) == nil{
            UserDefaults.standard.setValue("favorites", forKey: SearchFilterSetting.sortingKey, synchronizeToCloud: true)
        }
        
        if UserDefaults.standard.value(forKey: SearchFilterSetting.orderKey) == nil{
            UserDefaults.standard.setValue("desc", forKey: SearchFilterSetting.orderKey, synchronizeToCloud: true)
        }
        
        if UserDefaults.standard.value(forKey: SearchFilterSetting.purityKey) == nil{
            UserDefaults.standard.setValue("100", forKey: SearchFilterSetting.purityKey, synchronizeToCloud: true)
        }
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selfTapGesAction)))
        
        addSubview(blurV)
        blurV.layer.masksToBounds = true
        blurV.alpha = 0
        blurV.snp.remakeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(WidthScale(430))
        }
        
        blurV.contentView.addSubview(categoriesL)
        categoriesL.text = "类型"
        categoriesL.textColor = Colors.whiteTextColor
        categoriesL.font = UIFont.boldSystemFont(ofSize: WidthScale(16))
        categoriesL.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().inset(WidthScale(20))
        }
        
        for (index, btn) in categoriesBtnArr.enumerated(){
            blurV.contentView.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(categoriesL.snp.bottom).offset(WidthScale(10))
                make.size.equalTo(buttonSize)
                make.left.equalToSuperview().offset(WidthScale(20) + CGFloat(index) * (buttonSize.width + WidthScale(10)))
            }
            btn.addTarget(self, action: #selector(categoriesBtnAction), for: .touchUpInside)
            btn.tag = index + 100
            btn.backgroundColor = Colors.grayColor
            btn.setTitleColor(.gray, for: .normal)
            btn.setTitleColor(.red, for: .selected)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: WidthScale(14))
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = WidthScale(8)
            switch index {
            case 0:
                btn.setTitle("普通", for: .normal)
            case 1:
                btn.setTitle("动漫", for: .normal)
            case 2:
                btn.setTitle("人物", for: .normal)
            default:
                break
            }
        }
        
        if let category = UserDefaults.standard.value(forKey: SearchFilterSetting.categoriesKey) as? String{
            
            var num = Int(category) ?? 0
            
            if num >= 100 {
                categoriesBtnArr[0].isSelected = true
                num -= 100
            }
            
            if num >= 10 {
                categoriesBtnArr[1].isSelected = true
                num -= 10
            }
            
            
            if num >= 1 {
                categoriesBtnArr[2].isSelected = true
            }
            
        }
        
        blurV.contentView.addSubview(sortingL)
        sortingL.text = "排序类型"
        sortingL.textColor = Colors.whiteTextColor
        sortingL.font = UIFont.boldSystemFont(ofSize: WidthScale(16))
        sortingL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(WidthScale(20))
            make.top.equalTo(categoriesBtnArr.last!.snp.bottom).offset(WidthScale(10))
        }
        
        for (index, btn) in sortingBtnArr.enumerated(){
            blurV.contentView.addSubview(btn)
            btn.tag = index + 100
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(sortingL.snp.bottom).offset(WidthScale(10))
                make.size.equalTo(buttonSize)
                make.left.equalToSuperview().offset(WidthScale(20) + CGFloat(index) * (buttonSize.width + WidthScale(10)))
            }
            btn.addTarget(self, action: #selector(sortingBtnAction), for: .touchUpInside)
            btn.tag = index + 100
            btn.backgroundColor = Colors.grayColor
            btn.setTitleColor(.gray, for: .normal)
            btn.setTitleColor(.red, for: .selected)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: WidthScale(14))
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = WidthScale(8)
            switch index {
            case 0:
                btn.setTitle("相关性", for: .normal)
            case 1:
                btn.setTitle("添加日期", for: .normal)
            case 2:
                btn.setTitle("收藏数", for: .normal)
            case 3:
                btn.setTitle("随机", for: .normal)
            default:
                break
            }
        }
        
        if let sorting = UserDefaults.standard.value(forKey: SearchFilterSetting.sortingKey) as? String{
            switch sorting {
            case "relevance":
                sortingBtnArr[0].isSelected = true
            case "date_added":
                sortingBtnArr[1].isSelected = true
            case "favorites":
                sortingBtnArr[2].isSelected = true
            case "random":
                sortingBtnArr[3].isSelected = true
            default:
                break
            }
        }
        
        blurV.contentView.addSubview(orderL)
        orderL.text = "排序"
        orderL.textColor = Colors.whiteTextColor
        orderL.font = UIFont.boldSystemFont(ofSize: WidthScale(16))
        orderL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(WidthScale(20))
            make.top.equalTo(sortingBtnArr.last!.snp.bottom).offset(WidthScale(10))
        }
        
        for (index, btn) in orderBtnArr.enumerated(){
            blurV.contentView.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(orderL.snp.bottom).offset(WidthScale(10))
                make.size.equalTo(buttonSize)
                make.left.equalToSuperview().offset(WidthScale(20) + CGFloat(index) * (buttonSize.width + WidthScale(10)))
            }
            btn.addTarget(self, action: #selector(orderBtnAction), for: .touchUpInside)
            btn.tag = index + 100
            btn.backgroundColor = Colors.grayColor
            btn.setTitleColor(.gray, for: .normal)
            btn.setTitleColor(.red, for: .selected)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: WidthScale(14))
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = WidthScale(8)
            switch index {
            case 0:
                btn.setTitle("降序", for: .normal)
            case 1:
                btn.setTitle("升序", for: .normal)
            default:
                break
            }
        }
        
        if let order = UserDefaults.standard.value(forKey: SearchFilterSetting.orderKey) as? String{
            switch order {
            case "desc":
                orderBtnArr[0].isSelected = true
            case "asc":
                orderBtnArr[1].isSelected = true
            default:
                break
            }
        }
        
        blurV.contentView.addSubview(purityL)
        purityL.text = "级别"
        purityL.textColor = Colors.whiteTextColor
        purityL.font = UIFont.boldSystemFont(ofSize: WidthScale(16))
        purityL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(WidthScale(20))
            make.top.equalTo(orderBtnArr.last!.snp.bottom).offset(WidthScale(10))
        }
        
        for (index, btn) in purityBtnArr.enumerated(){
            blurV.contentView.addSubview(btn)
            btn.tag = index + 100
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(purityL.snp.bottom).offset(WidthScale(10))
                make.size.equalTo(buttonSize)
                make.left.equalToSuperview().offset(WidthScale(20) + CGFloat(index) * (buttonSize.width + WidthScale(10)))
            }
            btn.addTarget(self, action: #selector(purityBtnAction), for: .touchUpInside)
            btn.tag = index + 100
            btn.backgroundColor = Colors.grayColor
            btn.setTitleColor(.gray, for: .normal)
            btn.setTitleColor(.red, for: .selected)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: WidthScale(14))
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = WidthScale(8)
            switch index {
            case 0:
                btn.setTitle("SFW", for: .normal)
            case 1:
                btn.setTitle("sketchy", for: .normal)
            case 2:
                btn.setTitle("NSFW", for: .normal)
            default:
                break
            }
        }
        
        if let purity = UserDefaults.standard.value(forKey: SearchFilterSetting.purityKey) as? String{
            
            var num = Int(purity) ?? 0
            
            if num >= 100 {
                purityBtnArr[0].isSelected = true
                num -= 100
            }
            
            if num >= 10 {
                purityBtnArr[1].isSelected = true
                num -= 10
            }
            
            if num >= 1 {
                purityBtnArr[2].isSelected = true
            }
            
        }
        
        blurV.contentView.addSubview(colorL)
        colorL.text = "颜色"
        colorL.textColor = Colors.whiteTextColor
        colorL.font = UIFont.boldSystemFont(ofSize: WidthScale(16))
        colorL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(WidthScale(20))
            make.top.equalTo(purityBtnArr.last!.snp.bottom).offset(WidthScale(10))
        }
        
        for (index, btn) in colorBtnArr.enumerated(){
            blurV.contentView.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(colorL.snp.bottom).offset(WidthScale(10))
                make.width.height.equalTo(buttonSize.height)
                make.left.equalToSuperview().offset(WidthScale(20) + CGFloat(index) * (buttonSize.height + WidthScale(10)))
            }
            btn.addTarget(self, action: #selector(colorBtnAction), for: .touchUpInside)
            btn.tag = index + 100
            btn.setTitleColor(.clear, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: WidthScale(11))
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = buttonSize.height / 2
            btn.layer.borderColor = HEXCOLOR(h: 0xf8d256, alpha: 1.0).cgColor
            btn.layer.borderWidth = WidthScale(0)
            switch index {
            case 0:
                btn.setTitle("全部", for: .normal)
                btn.setTitleColor(Colors.whiteTextColor, for: .normal)
                btn.layer.borderWidth = WidthScale(2)
            case 1:
                btn.setTitle("cc3333", for: .normal)
                btn.backgroundColor = HEXCOLOR(h: 0xcc3333, alpha: 1.0)
            case 2:
                btn.setTitle("0099cc", for: .normal)
                btn.backgroundColor = HEXCOLOR(h: 0x0099cc, alpha: 1.0)
            case 3:
                btn.setTitle("77cc33", for: .normal)
                btn.backgroundColor = HEXCOLOR(h: 0x77cc33, alpha: 1.0)
            case 4:
                btn.setTitle("ffff00", for: .normal)
                btn.layer.borderColor = HEXCOLOR(h: 0x4facf2, alpha: 1.0).cgColor
                btn.backgroundColor = HEXCOLOR(h: 0xffff00, alpha: 1.0)
            case 5:
                btn.setTitle("ea4c88", for: .normal)
                btn.backgroundColor = HEXCOLOR(h: 0xea4c88, alpha: 1.0)
            case 6:
                btn.setTitle("ffffff", for: .normal)
                btn.backgroundColor = HEXCOLOR(h: 0xffffff, alpha: 1.0)
            default:
                break
            }
        }
        
        if let purity = UserDefaults.standard.value(forKey: SearchFilterSetting.purityKey) as? String{
            
            var num = Int(purity) ?? 0
            
            if num >= 100 {
                purityBtnArr[0].isSelected = true
                num -= 100
            }
            
            if num >= 10 {
                purityBtnArr[1].isSelected = true
                num -= 10
            }
            
            if num >= 1 {
                purityBtnArr[2].isSelected = true
            }
            
        }
        
        blurV.contentView.addSubview(searchBtn)
        searchBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(WidthScale(20))
            make.size.equalTo(CGSize(width: WidthScale(100), height: WidthScale(30)))
            make.centerX.equalToSuperview()
        }
        searchBtn.setTitle("刷 新", for: .normal)
        searchBtn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        searchBtn.backgroundColor = HEXCOLOR(h: 0x2c6eac, alpha: 0.8)
        searchBtn.setTitleColor(Colors.whiteTextColor, for: .normal)
        searchBtn.titleLabel?.font = UIFont.systemFont(ofSize: WidthScale(16))
        searchBtn.layer.masksToBounds = true
        searchBtn.layer.cornerRadius = WidthScale(8)
        
    }
    
    @objc func colorBtnAction(sender: UIButton){
        
        for btn in colorBtnArr{
            btn.layer.borderWidth = btn == sender ? WidthScale(2) : 0
            if btn == sender, let text = btn.titleLabel?.text{
                if text == "全部"{
                    SearchFilterSetting.color = ""
                }else{
                    SearchFilterSetting.color = text
                }
            }
        }
        
    }
    
    @objc func searchAction(){
        hide()
        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchImg()
    }
    
    func show(){
        if self.superview == nil{
            UIViewController.getCurrentViewCtrl().view.addSubview(self)
        }
        self.snp.remakeConstraints { (make) in
            make.top.equalTo(self.superview!.snp.top).offset(NavPlusStatusH)
            make.height.equalTo(0)
            make.left.right.equalToSuperview()
        }
        blurV.snp.remakeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0)
        }
        blurV.alpha = 0
        self.superview?.layoutIfNeeded()
        self.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.snp.remakeConstraints { (make) in
                make.top.equalTo(self.superview!.snp.top).offset(NavPlusStatusH)
                make.height.equalTo(SCREEN_HEIGHT - NavPlusStatusH)
                make.left.right.equalToSuperview()
            }
            self.blurV.snp.remakeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(WidthScale(430))
            }
            self.blurV.alpha = 1
            self.superview?.layoutIfNeeded()
        } completion: { (completed) in
            
        }
    }
    
    @objc func selfTapGesAction(sender: UITapGestureRecognizer){
        
        guard !blurV.frame.contains(sender.location(in: self)) else {
            return
        }
        hide()
    }
    
    func hide(){
        if self.superview == nil{
            UIViewController.getCurrentViewCtrl().view.addSubview(self)
        }
        blurV.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.snp.remakeConstraints { (make) in
                make.top.equalTo(self.superview!.snp.top).offset(NavPlusStatusH)
                make.height.equalTo(0)
                make.left.right.equalToSuperview()
            }
            self.blurV.snp.remakeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(0)
            }
            self.blurV.alpha = 0
            self.superview?.layoutIfNeeded()
        } completion: { (completed) in
            self.isHidden = true
        }
    }
    
    @objc func categoriesBtnAction(sender: UIButton){
        
        sender.isSelected = !sender.isSelected
        
        var categories: Int = 0
        
        for (index, btn) in categoriesBtnArr.enumerated(){
            switch index {
            case 0:
                if btn.isSelected{
                    categories += 100
                }
            case 1:
                if btn.isSelected{
                    categories += 10
                }
            case 2:
                if btn.isSelected{
                    categories += 1
                }
            default:
                break
            }
        }
        
        var categoriesStr = String(categories)
        let length = categoriesStr.count
        for _ in 0 ..< (3 - length){
            categoriesStr.insert("0", at: categoriesStr.startIndex)
        }
        UserDefaults.standard.setValue(categoriesStr, forKey: SearchFilterSetting.categoriesKey, synchronizeToCloud: true)
    }
    
    @objc func purityBtnAction(sender: UIButton){
        
        sender.isSelected = !sender.isSelected
        
        var purity: Int = 0
        
        for (index, btn) in purityBtnArr.enumerated(){
            switch index {
            case 0:
                if btn.isSelected{
                    purity += 100
                }
            case 1:
                if btn.isSelected{
                    purity += 10
                }
            case 2:
                if btn.isSelected{
                    purity += 1
                }
            default:
                break
            }
        }
        
        var purityStr = String(purity)
        let length = purityStr.count
        for _ in 0 ..< (3 - length){
            purityStr.insert("0", at: purityStr.startIndex)
        }
        UserDefaults.standard.setValue(purityStr, forKey: SearchFilterSetting.purityKey, synchronizeToCloud: true)
    }
    
    @objc func sortingBtnAction(sender: UIButton){
        
        for btn in sortingBtnArr {
            btn.isSelected = btn == sender
            if btn == sender{
                switch btn.titleLabel?.text {
                case "相关性":
                    UserDefaults.standard.setValue("relevance", forKey: SearchFilterSetting.sortingKey, synchronizeToCloud: true)
                case "添加日期":
                    UserDefaults.standard.setValue("date_added", forKey: SearchFilterSetting.sortingKey, synchronizeToCloud: true)
                case "收藏数":
                    UserDefaults.standard.setValue("favorites", forKey: SearchFilterSetting.sortingKey, synchronizeToCloud: true)
                case "随机":
                    UserDefaults.standard.setValue("random", forKey: SearchFilterSetting.sortingKey, synchronizeToCloud: true)
                default:
                    break
                }
            }
        }
        
    }
    
    @objc func orderBtnAction(sender: UIButton){
        
        for btn in orderBtnArr {
            btn.isSelected = btn == sender
            if btn == sender{
                switch btn.titleLabel?.text {
                case "升序":
                    UserDefaults.standard.setValue("asc", forKey: SearchFilterSetting.orderKey)
                case "降序":
                    UserDefaults.standard.setValue("desc", forKey: SearchFilterSetting.orderKey)
                default:
                    break
                }
            }
        }
        
    }


}
