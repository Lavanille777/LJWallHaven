//
//  ImageInfoView.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/18.
//

import UIKit

class ImageInfoView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var panGesBlock: ((Any?)->())? {
        didSet{
            if let panGesBlock = panGesBlock{
                addGestureRecognizer(UIPanGestureRecognizer(actionBlock: panGesBlock))
            }
        }
    }
    
    var frameBeforeEnded: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var blurV: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    
    weak var browser: LJPhotoBrowser?
    
    var closeBtn: UIButton = UIButton()
    
    var resolutionTitleL: UILabel = UILabel()
    
    var resolutionL: UILabel = UILabel()
    
    var sizeTitleL: UILabel = UILabel()
    
    var sizeL: UILabel = UILabel()
    
    var tagsTitleL: UILabel = UILabel()
    
    var sourceTitleL: UILabel = UILabel()
    
    var sourceL: UILabel = UILabel()
    
    var delegate: LJPhotoBrowser?
    
    var collectEnable: Bool = false
    
    var model: WallpaperInfoModel = WallpaperInfoModel(){
        didSet{
            collectEnable = true
            resolutionL.text = model.resolution
            sizeL.text = String(format: "%.2fMB", Double(model.file_size) / 1024.0 / 1024.0)
            sourceL.text = model.source == "" ? "暂无来源" : model.source
            Dprint("didSetModel======\(model.isCollected)")
            tagsCollectionV.reloadData()
            toolCollectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tagsCollectionV: UICollectionView = {
        
        let flowLayout = TagCollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = WidthScale(10)
        flowLayout.minimumLineSpacing = WidthScale(10)
        flowLayout.delegate = self
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
    
    var tagsCollectionVHeight: CGFloat = 0{
        didSet{
            tagsCollectionV.snp.remakeConstraints { (make) in
                make.top.equalTo(tagsTitleL.snp.bottom).offset(WidthScale(10))
                make.height.equalTo(tagsCollectionVHeight >= (WidthScale(150) + IPHONEX_BH + IPHONEX_TH) ? (WidthScale(150) + IPHONEX_BH + IPHONEX_TH) : tagsCollectionVHeight)
                make.left.equalToSuperview().inset(WidthScale(20))
                make.right.equalToSuperview().inset(WidthScale(5))
            }
            self.layoutIfNeeded()
        }
    }
    
    var toolTitleArr: [String] = ["保存到相册","相关的图","隐藏工具栏","收藏"]
    
    let itemWidth: CGFloat = WidthScale(55)
    
    let minimumInteritemSpacing: CGFloat = WidthScale(15)
    
    lazy var toolCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing
        flowLayout.itemSize = CGSize(width: itemWidth, height: TabBarHeight)
        
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ToolViewCell.self, forCellWithReuseIdentifier: "ToolViewCell")
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.tag = 2
        
        return collectionView
    }()
    
    func setupUI(){
        
        backgroundColor = .clear
        
        self.addSubview(blurV)
        blurV.layer.cornerRadius = WidthScale(20)
        blurV.layer.masksToBounds = true
        blurV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        blurV.contentView.addSubview(closeBtn)
        closeBtn.setBackgroundImage(UIImage(systemName: "chevron.compact.down"), for: .normal)
        //        closeBtn.addTarget(self, action: #selector(dismissVCAction), for: .touchUpInside)
        closeBtn.tintColor = .white
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: WidthScale(50), height: WidthScale(30)))
        }
        
        blurV.contentView.addSubview(toolCollectionView)
        toolCollectionView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(WidthScale(30))
            make.height.equalTo(TabBarHeight)
            make.width.equalTo(CGFloat(toolTitleArr.count) * (itemWidth + minimumInteritemSpacing) - minimumInteritemSpacing)
        }
        
        blurV.contentView.addSubview(resolutionTitleL)
        resolutionTitleL.font = UIFont.boldSystemFont(ofSize: WidthScale(22))
        resolutionTitleL.text = "尺寸"
        resolutionTitleL.textColor = .white
        resolutionTitleL.snp.makeConstraints { (make) in
            make.top.equalTo(toolCollectionView.snp.bottom).offset(WidthScale(22))
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
        if collectionView.tag == 2{
            return CGSize(width: itemWidth, height: TabBarHeight)
        }else{
            let cell = TagCollectionViewCell()
            
            cell.tagLabel.text = model.tags[indexPath.item].name
            
            cell.tagLabel.sizeToFit()
            
            return CGSize(width: ceil(cell.tagLabel.frame.size.width), height: ceil(cell.tagLabel.frame.size.height))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2{
            return toolTitleArr.count
        }
        return model.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToolViewCell", for: indexPath) as! ToolViewCell
            cell.iconImgV.tintColor = .white
            cell.iconImgV.image = nil
            switch toolTitleArr[indexPath.item] {
            case "收藏":
                Dprint("cellForItemAt======\(model.isCollected)")
                cell.iconImgV.image = UIImage(systemName: model.isCollected ? "heart.fill" : "heart")
                cell.iconImgV.tintColor = HEXCOLOR(h: 0xF08080, alpha: 1.0)
            case "保存到相册":
                cell.iconImgV.image = UIImage(systemName: "tray.and.arrow.down.fill")
            case "相关的图":
                cell.iconImgV.image = UIImage(systemName: "safari")
            case "隐藏工具栏":
                cell.iconImgV.image = UIImage(systemName: "eye.slash")
            case "显示原图":
                cell.iconImgV.image = UIImage(systemName: "square.and.arrow.down")
            default:
                break
            }
            
            cell.titleL.text = toolTitleArr[indexPath.item]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
            cell.tagLabel.text = model.tags[indexPath.item].name
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        if collectionView.tag == 2{
            
            switch toolTitleArr[indexPath.item] {
            case "详细信息":

                break
            case "保存到相册":
                if let image = delegate.currentCell?.imageView.image{
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(image:didFinishSavingWithError:contextInfo:)), nil)
                }
            case "相关的图":
                TabBarManager.shared().mainTabbarController.selectedIndex = 0
                
                delegate.hideInfoView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    delegate.dismiss(animated: true) {
                        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchTextFiled.textFiled.text = self.model.id
                        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchImg(isLike: true)
                    }
                }
            break
            case "收藏":
                
                if collectEnable{
                    let generator = UINotificationFeedbackGenerator()
                    collectEnable = false
                    if model.isCollected{
                        if SQLManager.deleteFromCollection(model) <= 0{
                            UIView.makeToast("收藏夹删除失败")
                            generator.notificationOccurred(.error)
                        }else{
                            generator.notificationOccurred(.success)
                            model.isCollected = false
                            if let cell = delegate.delegateCell{
                                cell.collectBtn.isSelected = false
                                cell.model = model
                                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationName.CollectionStateChaged), object: nil, userInfo: ["cell": delegate.delegateCell as Any])
                            }
                        }
                    }else{
                        if SQLManager.insertCollection(model) <= 0{
                            UIView.makeToast("加入收藏夹失败")
                            generator.notificationOccurred(.error)
                        }else{
                            generator.notificationOccurred(.success)
                            model.isCollected = true
                            if let cell = delegate.delegateCell{
                                delegate.delegateCell?.model = model
                                cell.collectBtn.isSelected = true
                            }
                        }
                    }
                    toolCollectionView.reloadData()
                    collectEnable = true
                }
                
            case "隐藏工具栏":
                delegate.isShowToolView = false
                UIView.makeToast("长按可显示或隐藏工具栏")
            case "显示原图":
                delegate.loadOriginalImage()
            default:
                break
            }

        }else{
            let tag = model.tags[indexPath.item].name
            
            let alert = UIAlertController(title: tag, message: nil, preferredStyle: .actionSheet)
            
            alert.overrideUserInterfaceStyle = .dark
            
            let action1 = UIAlertAction(title: "复制标签", style: .default) { (alert) in
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = tag
            }
            let action2 = UIAlertAction(title: "搜索标签", style: .default) { (alert) in
                UIView.startLoading()
                
                
                delegate.dismiss(animated: true) {
                    TabBarManager.shared().mainTabbarController.selectedIndex = 0
                    TabBarManager.shared().mainTabbarController.pictureFlowVC.searchTextFiled.placeHolder.isHidden = true
                    TabBarManager.shared().mainTabbarController.pictureFlowVC.searchTextFiled.textFiled.text = tag
                    TabBarManager.shared().mainTabbarController.pictureFlowVC.searchImg()
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
            delegate.present(alert, animated: true, completion: nil)
        }
        

    }
    
    @objc func dismissVCAction(){
        
        
    }
    
    
    @objc func imageSaved(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let e = error {
            Dprint(e)
        } else {
            UIView.makeToast("保存成功")
        }
    }
}

class TagCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    weak var delegate: ImageInfoView?
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let answer = super.layoutAttributesForElements(in: rect)
        for (index,value) in (answer?.enumerated())!
        {
            let currentLayoutAttributes :UICollectionViewLayoutAttributes = value
            let maximumSpacing = WidthScale(10)
            if index > 0{
                let prevLayoutAttributes:UICollectionViewLayoutAttributes = answer![index - 1]
                
                let origin = prevLayoutAttributes.frame.maxX
                if(origin + CGFloat(maximumSpacing) + currentLayoutAttributes.frame.size.width <= self.collectionViewContentSize.width) {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.x = origin + CGFloat(maximumSpacing)
                    frame.origin.y = prevLayoutAttributes.frame.minY
                    currentLayoutAttributes.frame = frame
                }else{
                    currentLayoutAttributes.frame.origin.y = prevLayoutAttributes.frame.maxY + maximumSpacing
                    currentLayoutAttributes.frame.origin.x = 0
                }
            }else{
                currentLayoutAttributes.frame.origin.x = 0
            }
            if index == (answer?.count ?? 0) - 1, let delegate = delegate{
                delegate.tagsCollectionVHeight = currentLayoutAttributes.frame.maxY
            }
        }
        return answer
    }
    
}


