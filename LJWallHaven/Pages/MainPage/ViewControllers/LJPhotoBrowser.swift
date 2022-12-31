//
//  LJPhotoBrowser.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/3.
//

import UIKit
import JXPhotoBrowser
import SDWebImage
import YYKit

class ToolViewCell: UICollectionViewCell {
    
    var iconImgV: UIImageView = UIImageView()
    
    var titleL: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        contentView.addSubview(iconImgV)
        iconImgV.tintColor = .white
        iconImgV.contentMode = .center
        iconImgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(25)
        }
        
        contentView.addSubview(titleL)
        titleL.textColor = .white
        titleL.font = UIFont.boldSystemFont(ofSize: 11)
        titleL.snp.makeConstraints { (make) in
            make.top.equalTo(iconImgV.snp.bottom)
            make.centerX.equalTo(iconImgV)
        }
    }
    
}

class LJPhotoBrowser: JXPhotoBrowser {
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    weak var pictureFlowViewController: PictureFlowViewController?
    
    let progressView: LJCycleProgressView = LJCycleProgressView.init(withWidth: WidthScale(3), radious: WidthScale(15), trackColor: .black, progressStartColor: .white, progressEndColor: .white)
    
    lazy var toolView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    
    var placeHolderImg: UIImage?{
        didSet{
            self.reloadCellAtIndex = { context in
                let browserCell = context.cell as? JXPhotoBrowserImageCell
                browserCell?.scrollView.maximumZoomScale = 8.0
                if browserCell?.imageView.image == nil{
                    browserCell?.imageView.image = self.placeHolderImg
                }
            }
        }
    }
    
    var imageInfoView = ImageInfoView()
    
    var model: WallpaperInfoModel = WallpaperInfoModel(){
        didSet{
            WallPaperInfoManager.shared.getWallpaperBy(id: model.id, isAuthentic: true) { (model, error) in
                guard error == nil else{
                    Dprint(error)
                    return
                }
                if let model = model{
                    self.infoModel = model
                }
            }
        }
    }
    
    var infoModel: WallpaperInfoModel = WallpaperInfoModel(){
        didSet{
            imageInfoView.model = infoModel
        }
    }
    
    var currentCell: JXPhotoBrowserImageCell?{
        didSet{
            if oldValue != currentCell{
                switch netWordState{
                case .ethernetOrWiFi:
                    imageInfoView.toolTitleArr = ["保存到相册","相关的图","隐藏工具栏","收藏"]
                    loadOriginalImage()
                case .cellular:
                    DispatchQueue.global().async {
                        if YYImageCache.shared().getImageForKey(self.model.path, with: .all) == nil && Setting.notAutoLoad{
                            self.imageInfoView.toolTitleArr = ["保存到相册","相关的图","隐藏工具栏","收藏", "显示原图"]
                        }else{
                            DispatchQueue.main.async {
                                self.loadOriginalImage()
                            }
                        }
                    }
                case .notReachable:
                    break
                }
            }
        }
    }
    
    var imageInfoViewController = ImageInfoViewController()
    
    var delegateCell:PictureFlowCollectionViewCell?
    
    var isShowToolView: Bool = true{
        didSet{
            if oldValue != isShowToolView{
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                    self.imageInfoView.frame = CGRect(x: 0, y: self.isShowToolView ? SCREEN_HEIGHT - 100 : SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                } completion: { (completed) in
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(LongPressGestureAction))
        longPress.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPress)
        
        self.browserView.addSubview(toolView)
        toolView.layer.cornerRadius = WidthScale(15)
        toolView.layer.masksToBounds = true
        self.toolView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(IPHONEX_BH + WidthScale(10))
            make.height.equalTo(self.isShowToolView ? TabBarHeight : 0)
        }
        
        browserView.addSubview(imageInfoView)
        imageInfoView.delegate = self
        imageInfoView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - 100, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        imageInfoView.closeBtn.layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
        imageInfoView.panGesBlock = {[weak self] (gesture) in
            
            guard let weakSelf = self else {
                return
            }
            
            if let gesture = gesture as? UIPanGestureRecognizer{
                let point = gesture.location(in: weakSelf.view)
                let velocit = gesture.velocity(in: weakSelf.view)
                let translation = gesture.translation(in: weakSelf.view)
                let target: CGFloat = weakSelf.imageInfoView.frameBeforeEnded.origin.y + translation.y
                Dprint("velocity=====\(velocit)")

                Dprint(translation.y)
                switch gesture.state {
                case .began:
                    weakSelf.imageInfoView.frameBeforeEnded = weakSelf.imageInfoView.frame
                case .changed:
                    if target > SCREEN_HEIGHT - 650 - IPHONEX_TH - IPHONEX_BH{
                        weakSelf.imageInfoView.frame = CGRect(x: 0, y: target, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                    }else{
                        weakSelf.imageInfoView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - 650 - IPHONEX_BH - IPHONEX_TH, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                    }
                case .ended:
                    if target + velocit.y < SCREEN_HEIGHT - TabBarPlusBH {
                        weakSelf.showInfoView()
                    }else{
                        weakSelf.hideInfoView()
                    }
                default:
                    break
                }

            }
            
        }

        
        ///环形进度条
        self.browserView.addSubview(progressView)
        progressView.isHidden = true
        progressView.snp.makeConstraints { (make) in
            make.bottom.equalTo(imageInfoView.snp.top).offset(-WidthScale(10))
            make.right.equalToSuperview().inset(WidthScale(20))
            make.width.height.equalTo(WidthScale(30))
        }
        
        self.browserView.cellWillAppear = {[weak self](cell, index) in
            if let weakSelf = self, let browserCell = cell as? JXPhotoBrowserImageCell{
                
                weakSelf.currentCell = browserCell
                browserCell.imageView.addObserver(weakSelf, forKeyPath: "frame", options: [.old, .new], context: nil)
                
                browserCell.panGestureClosure = {[weak self](alpha) in
                    if let weakSelf = self, weakSelf.isShowToolView{
                        weakSelf.imageInfoView.alpha = alpha
                    }
                }
                
                weakSelf.imageInfoView.toolCollectionView.reloadData()
                weakSelf.imageInfoView.toolCollectionView.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().inset(WidthScale(30))
                    make.height.equalTo(TabBarHeight)
                    make.width.equalTo(CGFloat(weakSelf.imageInfoView.toolTitleArr.count) * (weakSelf.imageInfoView.itemWidth + weakSelf.imageInfoView.minimumInteritemSpacing) - weakSelf.imageInfoView.minimumInteritemSpacing)
                }
            }
            
        }
        
        imageInfoViewController.view.layoutIfNeeded()
        
        if let isShowToolView = UserDefaults.standard.value(forKey: Setting.autoDisplayToolViewKey) as? Bool{
            self.isShowToolView = isShowToolView
        }
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "frame", let change = change{
            print(change[.oldKey])
            
            print(change[.newKey]) 
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageInfoView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.imageInfoView.alpha = 1
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.imageInfoView.alpha = 0
        }
    }

    func loadOriginalImage(){
        Dprint("加载原图")
        if let url = URL(string: model.path){
            currentCell?.imageView.setImageWith(url, placeholder: placeHolderImg, options: [], progress: { (receivedSize, totalSize) in
                DispatchQueue.main.async {
                    self.progressView.isHidden = false
                    self.progressView.setProgress(progress: CGFloat(receivedSize)/CGFloat(totalSize), time: 0, animate: false)
                }
            }, transform: nil, completion: { (image, url, type, stage, error) in
                if image != nil{
                    DispatchQueue.main.async {
                        self.progressView.isHidden = true
                        self.imageInfoView.toolTitleArr = ["保存到相册","相关的图","隐藏工具栏","收藏"]
                        self.imageInfoView.toolCollectionView.reloadData()
                        self.imageInfoView.toolCollectionView.snp.remakeConstraints { (make) in
                            make.centerX.equalToSuperview()
                            make.top.equalToSuperview().inset(WidthScale(30))
                            make.height.equalTo(TabBarHeight)
                            make.width.equalTo(CGFloat(self.imageInfoView.toolTitleArr.count) * (self.imageInfoView.itemWidth + self.imageInfoView.minimumInteritemSpacing) - self.imageInfoView.minimumInteritemSpacing)
                        }
                    }
                }
                
                if let error = error as? URLError{
                    if error.code.rawValue == -1001{
                        if (UIViewController.getCurrentViewCtrl() is LJPhotoBrowser || UIViewController.getCurrentViewCtrl() is ImageInfoViewController) && url.absoluteString == self.model.path{
                            self.progressView.isHidden = true
                            self.imageInfoView.toolTitleArr = ["保存到相册","相关的图","隐藏工具栏","收藏","显示原图"]
                            self.imageInfoView.toolCollectionView.snp.remakeConstraints { (make) in
                                make.centerX.equalToSuperview()
                                make.top.equalToSuperview().inset(WidthScale(30))
                                make.height.equalTo(TabBarHeight)
                                make.width.equalTo(CGFloat(self.imageInfoView.toolTitleArr.count) * (self.imageInfoView.itemWidth + self.imageInfoView.minimumInteritemSpacing) - self.imageInfoView.minimumInteritemSpacing)
                            }
                            self.imageInfoView.toolCollectionView.reloadData()
                            UIView.makeToast("加载超时，点击显示原图重新加载")
                        }
                    }
                }
            })
        }
    }
    
    func hideInfoView(){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.imageInfoView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - 100, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        } completion: { (finished) in
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
                self.imageInfoView.closeBtn.layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
                
            } completion: { (finished) in
                
            }
        }
    }
    
    func showInfoView(){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.imageInfoView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - 600 - IPHONEX_BH, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        } completion: { (finished) in
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
                self.imageInfoView.closeBtn.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
            } completion: { (finished) in
                
            }
        }
    }
    
    @objc func LongPressGestureAction(ges: UILongPressGestureRecognizer){
        if ges.state == .began{
            isShowToolView = !isShowToolView
        }
    }
    
    
}
