//
//  CategoryViewController.swift
//  LJWallHaven
//  热门分类页面
//  Created by 唐星宇 on 2021/3/5.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    var imageV: UIImageView = UIImageView()
    
    var maskV: UIImageView = UIImageView()
    
    var titleL: UILabel = UILabel()
    
    var gesture: UILongPressGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        gesture = self.addOncePressAnimation()
        contentView.layer.shadowColor = Colors.imageCellShadowColor.cgColor
        contentView.layer.shadowOffset = CGSize(width: WidthScale(5), height: WidthScale(5))
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowRadius = WidthScale(5)
        
        contentView.addSubview(imageV)
        imageV.layer.cornerRadius = WidthScale(10)
        imageV.layer.masksToBounds = true
        imageV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        imageV.addSubview(maskV)
        maskV.backgroundColor = HEXCOLOR(h: 0x000000, alpha: 0.3)
        maskV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        imageV.addSubview(titleL)
        titleL.textColor = HEXCOLOR(h: 0xf9d876, alpha: 1.0)
        titleL.font = UIFont.boldSystemFont(ofSize: WidthScale(18))
        titleL.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDidChange), name: NotificationName.TraitCollectionDidChange, object: nil)
    }
    
    @objc func darkModeDidChange(){
        contentView.layer.shadowColor = Colors.imageCellShadowColor.cgColor
    }
    
}

var categoryTitleArr: [(String, Int)] = [("动漫", 1), ("数码绘画", 479) ,("幻想艺术" ,853),("游戏", 55), ("自然", 37), ("城市", 17), ("室内", 3828), ("汽车", 314), ("大海", 307), ("天空", 2729),("猫咪", 43), ("狗子", 1702), ("山川", 328), ("模特", 424), ("科技", 1240), ("图纹",869), ("鲜花",1018), ("分形", 2212)]

class CategoryViewController: LJBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    lazy var categoryCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: WidthScale(100), height: WidthScale(100))
        flowLayout.minimumLineSpacing = WidthScale(20)
        flowLayout.minimumInteritemSpacing = WidthScale(10)
        flowLayout.sectionInset = UIEdgeInsets(top: NavPlusStatusH + WidthScale(10), left: WidthScale(20), bottom: TabBarPlusBH + WidthScale(10), right: WidthScale(20))
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = Colors.mainBackGroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "tableHeadV")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        createNavbar(navTitle: "热门分类", leftIsImage: false, leftStr: nil, rightIsImage: false, rightStr: nil, leftAction: nil, ringhtAction: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryTitleArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        cell.gesture?.delegate = self
        cell.titleL.text = categoryTitleArr[indexPath.row].0
        cell.imageV.image = UIImage(named: categoryTitleArr[indexPath.row].0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TabBarManager.shared().mainTabbarController.selectedIndex = 0
        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchTextFiled.placeHolder.isHidden = true
        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchTextFiled.textFiled.text = "id:\(categoryTitleArr[indexPath.row].1)"
        TabBarManager.shared().mainTabbarController.pictureFlowVC.searchImg()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
