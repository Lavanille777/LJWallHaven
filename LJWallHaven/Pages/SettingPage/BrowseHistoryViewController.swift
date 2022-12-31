//
//  BrowseHistoryViewController.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/2.
//

import UIKit
import MJRefresh
import JXPhotoBrowser
import YYKit

class BrowseHistoryViewController: LJBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, PictureFlowCollectionFlowLayoutDelegate {
    
    let pictureCollectionViewflowLayout = PictureFlowCollectionFlowLayout.init()
    
    lazy var pictureCollectionView:UICollectionView = {
        
        pictureCollectionViewflowLayout.minimumLineSpacing = WidthScale(10)
        pictureCollectionViewflowLayout.minimumInteritemSpacing = WidthScale(10)
        pictureCollectionViewflowLayout.sectionInset = UIEdgeInsets(top: NavPlusStatusH + WidthScale(10), left: WidthScale(10), bottom: TabBarPlusBH, right: WidthScale(10))
        pictureCollectionViewflowLayout.scrollDirection = .vertical
        pictureCollectionViewflowLayout.delegate = self
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: pictureCollectionViewflowLayout)
        collectionView.backgroundColor = Colors.mainBackGroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(PictureFlowCollectionViewCell.self, forCellWithReuseIdentifier: "PictureFlowCollectionViewCell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "tableHeadV")
        return collectionView
        
    }()
    
    var dataArr: [WallpaperInfoModel] = []{
        didSet{
            emptyResultView.isHidden = dataArr.count > 0
        }
    }
    
    var emptyResultView: EmptyResultView = EmptyResultView()
    
    ///类型 0-历史浏览 1-收藏夹
    var type: Int = 0
    
    init(withType type: Int) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionStateChagedAction), name: Notification.Name(NotificationName.CollectionStateChaged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryRecordDeletedAction), name: Notification.Name(NotificationName.HistoryRecordDeleted), object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.loadNewData()
        }
    }
    
    @objc func CollectionStateChagedAction(noti: Notification){
        if let userInfo = noti.userInfo,
           let cell = userInfo["cell"] as? PictureFlowCollectionViewCell,
           let indexPath = pictureCollectionView.indexPath(for: cell), type == 1{
            dataArr.remove(at: indexPath.item)
            pictureCollectionViewflowLayout.deleteIndexPath = indexPath
            pictureCollectionView.deleteItems(at: [indexPath])
        }
    }
    
    @objc func HistoryRecordDeletedAction(noti: Notification){
        if let userInfo = noti.userInfo,
           let cell = userInfo["cell"] as? PictureFlowCollectionViewCell,
           let indexPath = pictureCollectionView.indexPath(for: cell), type == 0{
            dataArr.remove(at: indexPath.item)
            pictureCollectionViewflowLayout.deleteIndexPath = indexPath
            pictureCollectionView.deleteItems(at: [indexPath])
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpUI(){
        
        view.addSubview(pictureCollectionView)
        pictureCollectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.loadMoreData()
        })
        pictureCollectionView.mj_header?.ignoredScrollViewContentInsetTop = -NavPlusStatusH
        pictureCollectionView.mj_footer?.ignoredScrollViewContentInsetBottom = -TabBarPlusBH
        pictureCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        pictureCollectionView.addSubview(emptyResultView)
        emptyResultView.isHidden = true
        emptyResultView.titleL.text = "还没有\(type == 0 ? "历史浏览" : "收藏")哦"
        emptyResultView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        createNavbar(navTitle: type == 0 ? "历史浏览" : "收藏夹", leftIsImage: true, leftStr: nil, rightIsImage: false, rightStr: nil, leftAction: nil, ringhtAction: nil)
        
    }
    
    func loadNewData(){
        
        switch type {
        case 0:
            dataArr = SQLManager.queryAllBrowseHistory() ?? []
        case 1:
            dataArr = SQLManager.queryAllCollection() ?? []
        default:
            break
        }
        
        pictureCollectionView.reloadData()
        
        pictureCollectionView.mj_footer?.isHidden = dataArr.count < collectionPageSize
    }
    
    func loadMoreData(){
        let arr = SQLManager.queryAllCollection(page: dataArr.count / collectionPageSize) ?? []
        dataArr.append(contentsOf: arr)
        pictureCollectionView.reloadData()
        pictureCollectionView.mj_footer?.isHidden = arr.count < collectionPageSize
        self.pictureCollectionView.mj_footer?.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureFlowCollectionViewCell", for: indexPath) as! PictureFlowCollectionViewCell
        cell.type = type
        cell.model = dataArr[indexPath.item]
        cell.collectBtn.isSelected = cell.model.isCollected
        if let url = URL(string: dataArr[indexPath.item].thumbs[.original] ?? ""){
            cell.imageView.setImageWith(url, options: [.setImageWithFadeAnimation])
            cell.contentView.layoutIfNeeded()
            cell.resolutionL.text = dataArr[indexPath.item].resolution
            switch dataArr[indexPath.item].category {
            case "general":
                cell.categoryL.textColor = HEXCOLOR(h: 0x8B4513, alpha: 1.0)
                cell.categoryL.backgroundColor = HEXCOLOR(h: 0xFFE7BA, alpha: 1.0)
                cell.categoryL.text = "普通"
            case "anime":
                cell.categoryL.backgroundColor = HEXCOLOR(h: 0xEEB4B4, alpha: 1.0)
                cell.categoryL.textColor = HEXCOLOR(h: 0x8B4513, alpha: 1.0)
                cell.categoryL.text = "动漫"
            case "people":
                cell.categoryL.backgroundColor = HEXCOLOR(h: 0x87CEFF, alpha: 1.0)
                cell.categoryL.textColor = HEXCOLOR(h: 0x8B4513, alpha: 1.0)
                cell.categoryL.text = "人物"
            default:
                cell.categoryL.text = dataArr[indexPath.item].category
            }
            cell.sizeL.text = String(format: "大小: %.2fMB", Double(dataArr[indexPath.item].file_size) / 1024.0 / 1024.0)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PictureFlowCollectionViewCell, cell.imageView.image != nil else {
            return
        }
        
        if type != 0{
            DispatchQueue.global().async {
                if SQLManager.insertBrowseHistory(self.dataArr[indexPath.item]) <= 0 {
                    Dprint("插入历史浏览数据库失败")
                }
            }
        }
        
        let imgBrowser: LJPhotoBrowser = LJPhotoBrowser()
        imgBrowser.delegateCell = cell
        imgBrowser.pictureFlowViewController = TabBarManager.shared().mainTabbarController.pictureFlowVC
        imgBrowser.numberOfItems = {
            1
        }
        imgBrowser.placeHolderImg = cell.imageView.image
        var model = dataArr[indexPath.item]
        WallPaperInfoManager.shared.getWallpaperBy(id: model.id) { (getModel, error) in
            guard error == nil else{
                Dprint(error)
                return
            }
            
            if let getModel = getModel{
                model = getModel
            }
        }
        imgBrowser.model = model
        imgBrowser.transitionAnimator = JXPhotoBrowserSmoothZoomAnimator(transitionViewAndFrame: { (index, destinationView) -> JXPhotoBrowserSmoothZoomAnimator.TransitionViewAndFrame? in
            let image = cell.imageView.image
            let transitionView = UIImageView(image: image)
            transitionView.contentMode = cell.imageView.contentMode
            transitionView.clipsToBounds = true
            let thumbnailFrame = cell.imageView.convert(cell.imageView.bounds, to: destinationView)
            return (transitionView, thumbnailFrame)
        })
        
        imgBrowser.show()
    }
    
    func setCellHeights(indexPath: IndexPath) -> CGFloat {
        
        guard indexPath.item < dataArr.count else {
            return 0
        }
        
        var height = dataArr[indexPath.item].dimension.y / dataArr[indexPath.item].dimension.x * WidthScale(172.5) + WidthScale(64)
        
        height = height.isNaN ? 0 : height
        
        return height
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard Setting.scrollAnimationEnable else {
            return
        }
        
        let speed = scrollView.contentOffset.y - preventOffset.y
        Dprint("scrollViewDidEndDecelerating===\(speed)")
        

        
        if let collectionV = scrollView as? UICollectionView{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let feedback = UIImpactFeedbackGenerator(style: .light)
                    feedback.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let feedback = UIImpactFeedbackGenerator(style: .soft)
                        feedback.impactOccurred()
                    }
                }
            }
            for cell in collectionV.visibleCells{
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                    var transform = CATransform3DIdentity
                    transform.m34 = -1/900
                    let rotation = CATransform3DRotate(transform, (cell.layer.transform.m32 / 2), 1, 0, 0)
                    cell.layer.transform = rotation
                } completion: { (finished) in
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                        var transform = CATransform3DIdentity
                        transform.m34 = -1/900
                        let rotation = CATransform3DRotate(transform, (cell.layer.transform.m32 / 2), 1, 0, 0)
                        cell.layer.transform = rotation
                    } completion: { (finished) in
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                            var transform = CATransform3DIdentity
                            transform.m34 = 0
                            let rotation = CATransform3DRotate(transform, 0, 1, 0, 0)
                            cell.layer.transform = rotation
                        } completion: { (finished) in
                            var feedback = UIImpactFeedbackGenerator(style: .soft)
                            feedback.impactOccurred()
                        }
                    }
                }
            }
        }

    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard Setting.scrollAnimationEnable else {
            return
        }
        
        let speed = scrollView.contentOffset.y - preventOffset.y
        Dprint("scrollViewDidEndScrollingAnimation===\(speed)")
        if let collectionV = scrollView as? UICollectionView{
            for cell in collectionV.visibleCells{
                var transform = CATransform3DIdentity
                transform.m34 = 0
                let rotation = CATransform3DRotate(transform, 0, 1, 0, 0)
                cell.layer.transform = rotation
            }
        }

    }
    
    var preventOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard Setting.scrollAnimationEnable else {
            return
        }
        
        let speed = scrollView.contentOffset.y - preventOffset.y
        
        preventOffset = scrollView.contentOffset
        Dprint("scrollViewDidScroll====\(speed)")
        if let collectionV = scrollView as? UICollectionView, fabsf(Float(speed)) > 5{
            for cell in collectionV.visibleCells{
                    var speedAngel:Double = 0
                    if (Double(speed) * 2) > 40{
                        speedAngel = 40
                    }else if (Double(speed) * 2) < -40{
                        speedAngel = -40
                    }else{
                        speedAngel = Double(speed) * 2
                    }
                    let angle = angleToRadian(-speedAngel)
                    var transform = CATransform3DIdentity
                    transform.m34 = -1.0 / 900
                    let rotation = CATransform3DRotate(transform, angle, 1, 0, 0)
                    cell.layer.transform = rotation
            }
        }
    }
    
}
