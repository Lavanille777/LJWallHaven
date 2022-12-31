//
//  ImageInfoViewController.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/4.
//

import UIKit

class ImageInfoViewController: LJBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var browser: LJPhotoBrowser?
    
    var closeBtn: UIButton = UIButton()
    
    var blurV: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
    
    var resolutionTitleL: UILabel = UILabel()
    
    var resolutionL: UILabel = UILabel()
    
    var sizeTitleL: UILabel = UILabel()
    
    var sizeL: UILabel = UILabel()
    
    var tagsTitleL: UILabel = UILabel()
    
    var sourceTitleL: UILabel = UILabel()
    
    var sourceL: UILabel = UILabel()
    
    var model: WallpaperInfoModel = WallpaperInfoModel(){
        didSet{
            resolutionL.text = model.resolution
            sizeL.text = String(format: "%.2fMB", Double(model.file_size) / 1024.0 / 1024.0)
            sourceL.text = model.source == "" ? "暂无来源" : model.source
            tagsCollectionV.reloadData()
        }
    }
    
    lazy var tagsCollectionV: UICollectionView = {
        
        let flowLayout = TagCollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = WidthScale(10)
        flowLayout.minimumLineSpacing = WidthScale(10)
//        flowLayout.delegate = self
        let collectionV = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionV.backgroundColor = .clear
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.contentInsetAdjustmentBehavior = .never
        collectionV.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCollectionViewCell")
        return collectionV
    }()
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"{
            if let oldSize = change?[.oldKey] as? CGSize, let newSize = change?[.newKey] as? CGSize{
                Dprint("\(oldSize), \(newSize)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    var tagsCollectionVHeight: CGFloat = 0{
        didSet{
            tagsCollectionV.snp.remakeConstraints { (make) in
                make.top.equalTo(tagsTitleL.snp.bottom).offset(WidthScale(10))
                make.height.equalTo(tagsCollectionVHeight >= (WidthScale(300) + IPHONEX_BH + IPHONEX_TH) ? (WidthScale(300) + IPHONEX_BH + IPHONEX_TH) : tagsCollectionVHeight)
                make.left.equalToSuperview().inset(WidthScale(20))
                make.right.equalToSuperview().inset(WidthScale(5))
            }
            view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        
        self.preferredContentSize = CGSize(width: SCREEN_WIDTH, height: WidthScale(200))
        
        view.addSubview(blurV)
        blurV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        blurV.contentView.addSubview(closeBtn)
        closeBtn.setBackgroundImage(UIImage(systemName: "chevron.compact.down"), for: .normal)
        closeBtn.addTarget(self, action: #selector(dismissVCAction), for: .touchUpInside)
        closeBtn.tintColor = .white
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(WidthScale(5))
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: WidthScale(50), height: WidthScale(30)))
        }
        blurV.layoutIfNeeded()
        closeBtn.layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
        
        blurV.contentView.addSubview(resolutionTitleL)
        resolutionTitleL.font = UIFont.boldSystemFont(ofSize: WidthScale(22))
        resolutionTitleL.text = "尺寸"
        resolutionTitleL.textColor = .white
        resolutionTitleL.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(WidthScale(30))
            make.left.equalToSuperview().inset(WidthScale(20))
        }
        
        blurV.contentView.addSubview(resolutionL)
        resolutionL.font = UIFont.systemFont(ofSize: WidthScale(20))
        resolutionL.textColor = .white
        resolutionL.snp.makeConstraints { (make) in
            make.top.equalTo(resolutionTitleL.snp.bottom).offset(WidthScale(10))
            make.left.equalToSuperview().inset(WidthScale(20))
        }
        
        blurV.contentView.addSubview(sizeTitleL)
        sizeTitleL.font = UIFont.boldSystemFont(ofSize: WidthScale(22))
        sizeTitleL.text = "图片大小"
        sizeTitleL.textColor = .white
        sizeTitleL.snp.makeConstraints { (make) in
            make.top.equalTo(resolutionL.snp.bottom).offset(WidthScale(15))
            make.left.equalToSuperview().inset(WidthScale(20))
        }
        
        blurV.contentView.addSubview(sizeL)
        sizeL.font = UIFont.systemFont(ofSize: WidthScale(20))
        sizeL.textColor = .white
        sizeL.snp.makeConstraints { (make) in
            make.top.equalTo(sizeTitleL.snp.bottom).offset(WidthScale(10))
            make.left.equalToSuperview().inset(WidthScale(20))
        }
        
        blurV.contentView.addSubview(tagsTitleL)
        tagsTitleL.font = UIFont.boldSystemFont(ofSize: WidthScale(22))
        tagsTitleL.text = "标签"
        tagsTitleL.textColor = .white
        tagsTitleL.snp.makeConstraints { (make) in
            make.top.equalTo(sizeL.snp.bottom).offset(WidthScale(15))
            make.left.equalToSuperview().inset(WidthScale(20))
        }
        
        blurV.contentView.addSubview(tagsCollectionV)
        tagsCollectionV.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        tagsCollectionV.snp.makeConstraints { (make) in
            make.top.equalTo(tagsTitleL.snp.bottom).offset(WidthScale(10))
            make.height.lessThanOrEqualTo(WidthScale(300))
            make.left.equalToSuperview().inset(WidthScale(20))
            make.right.equalToSuperview().inset(WidthScale(5))
        }
        
        blurV.contentView.addSubview(sourceTitleL)
        sourceTitleL.font = UIFont.boldSystemFont(ofSize: WidthScale(22))
        sourceTitleL.text = "来源"
        sourceTitleL.textColor = .white
        sourceTitleL.snp.makeConstraints { (make) in
            make.top.equalTo(tagsCollectionV.snp.bottom).offset(WidthScale(15))
            make.left.equalToSuperview().inset(WidthScale(20))
        }
        
        blurV.contentView.addSubview(sourceL)
        sourceL.textColor = HEXCOLOR(h: 0xf9d572, alpha: 1.0)
        sourceL.font = UIFont.systemFont(ofSize: WidthScale(14))
        sourceL.numberOfLines = 0
        sourceL.textAlignment = .left
        sourceL.isUserInteractionEnabled = true
        sourceL.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sourceLAction)))
        sourceL.snp.makeConstraints { (make) in
            make.top.equalTo(sourceTitleL.snp.bottom).offset(WidthScale(5))
            make.left.right.equalToSuperview().inset(WidthScale(20))
        }
        
    }
    
    @objc func sourceLAction(){
        if model.source != "", let url = URL.init(string: model.source){
            UIApplication.shared.open(url, options: [:]) { (completed) in
                
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = TagCollectionViewCell()
        
        cell.tagLabel.text = model.tags[indexPath.item].name
        
        cell.tagLabel.sizeToFit()
        
        return CGSize(width: ceil(cell.tagLabel.frame.size.width), height: ceil(cell.tagLabel.frame.size.height))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = model.tags[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tag = model.tags[indexPath.item].name
        
        let alert = UIAlertController(title: tag, message: nil, preferredStyle: .actionSheet)
        
        alert.overrideUserInterfaceStyle = .dark
        
        let action1 = UIAlertAction(title: "复制标签", style: .default) { (alert) in
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = tag
        }
        let action2 = UIAlertAction(title: "搜索标签", style: .default) { (alert) in
            UIView.startLoading()
            self.dismiss(animated: true) {
                if let browser = self.browser{
                    browser.dismiss(animated: true) {
                        TabBarManager.shared().mainTabbarController.selectedIndex = 0
                        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchTextFiled.placeHolder.isHidden = true
                        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchTextFiled.textFiled.text = tag
                        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchImg()
                    }
                }
            }
        }
        let action3 = UIAlertAction(title: "添加搜索宏", style: .default) { (alert) in
            let alert = LJAlertViewController(withInputPlaceHolder: "请输入宏名称", title: "宏名称", confirmTitle: nil, cancelTitle: nil) { (alert) in
                if let text = alert.inputTF.text, text != ""{
                    let model = SearchMacroModel()
                    model.key = text
                    model.value = tag
                    if SQLManager.insertSearchMacro(model) > 0{
                        UIView.makeToast("添加搜索宏成功")
                    }else{
                        UIView.makeToast("添加搜索宏失败")
                    }
                }else{
                    UIView.makeToast("名称不能为空")
                }
            }
            alert.inputTF.text = tag
            alert.show()
        }
        let action4 = UIAlertAction(title: "取消", style: .cancel) { (alert) in
            
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissVCAction(){
        self.dismiss(animated: true) {
            
        }
    }
    
}

class TagCollectionViewCell: UICollectionViewCell {
    
    var tagLabel: UIPaddingLabel = UIPaddingLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(tagLabel)
        tagLabel.textInsets = UIEdgeInsets(top: WidthScale(2), left: WidthScale(5), bottom: WidthScale(2), right: WidthScale(5))
        tagLabel.backgroundColor = HEXCOLOR(h: 0xf6e3bf, alpha: 1.0)
        tagLabel.layer.cornerRadius = WidthScale(5)
        tagLabel.layer.masksToBounds = true
        tagLabel.font = UIFont.systemFont(ofSize: WidthScale(16))
        tagLabel.textColor = HEXCOLOR(h: 0x353747, alpha: 1.0)
        tagLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}

