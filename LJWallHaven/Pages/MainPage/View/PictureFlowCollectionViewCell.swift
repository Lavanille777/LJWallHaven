//
//  PictureFlowCollectionViewCell.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/5.
//

import UIKit
import SDWebImage
import YYKit

class PictureFlowCollectionViewCell: UICollectionViewCell {
    
    var cardView: UIView = UIView()
    
    var imageView: UIImageView = UIImageView()
    
    var categoryL: UIPaddingLabel = UIPaddingLabel()
    
    var sizeL: UILabel = UILabel()
    
    var resolutionL: UILabel = UILabel()
    
    var collectBtn: UIButton = UIButton()
    
    var model: WallpaperInfoModel = WallpaperInfoModel()
    
    var trashBtn: UIButton = UIButton()
    
    //0 - 历史记录 1 - 通常
    var type: Int = 1{
        didSet{
            if type != oldValue{
                trashBtn.isHidden = type != 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowRadius = WidthScale(4)
        contentView.layer.shadowOffset = CGSize(width: WidthScale(4), height: WidthScale(4))
        contentView.layer.shadowColor = Colors.imageCellShadowColor.cgColor
        cardView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.layoutIfNeeded()
        cardView.backgroundColor = Colors.imageCellColor
        cardView.layer.masksToBounds = true
        cardView.layer.cornerRadius = WidthScale(10)
        
        cardView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(WidthScale(64))
        }
        
        cardView.addSubview(categoryL)
        categoryL.font = UIFont.boldSystemFont(ofSize: WidthScale(10))
        categoryL.textColor = HEXCOLOR(h: 0x8B4513, alpha: 1.0)
        categoryL.backgroundColor = HEXCOLOR(h: 0xFFE7BA, alpha: 1.0)
        categoryL.layer.masksToBounds = true
        categoryL.layer.cornerRadius = WidthScale(3)
        categoryL.textInsets = UIEdgeInsets(top: WidthScale(2), left: WidthScale(5), bottom: WidthScale(2), right: WidthScale(5))
        categoryL.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(WidthScale(10))
            make.left.equalToSuperview().inset(WidthScale(10))
        }
        
        cardView.addSubview(sizeL)
        sizeL.font = UIFont.systemFont(ofSize: WidthScale(12))
        sizeL.textColor = Colors.whiteTextColor
        sizeL.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(WidthScale(10))
            make.centerY.equalTo(categoryL)
        }
        
        cardView.addSubview(collectBtn)
        collectBtn.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        collectBtn.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .selected)
        collectBtn.addTarget(self, action: #selector(collectBtnAction), for: .touchUpInside)
        collectBtn.tintColor = HEXCOLOR(h: 0xF08080, alpha: 1.0)
        collectBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(WidthScale(5))
            make.right.equalToSuperview().inset(WidthScale(10))
            make.height.equalTo(WidthScale(24))
            make.width.equalTo(WidthScale(26))
        }
        
        cardView.addSubview(trashBtn)
        trashBtn.isHidden = true
        trashBtn.setBackgroundImage(UIImage(systemName: "trash"), for: .normal)
        trashBtn.addTarget(self, action: #selector(trashBtnAction), for: .touchUpInside)
        trashBtn.tintColor = .red
        trashBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(WidthScale(5))
            make.right.equalTo(collectBtn.snp.left).offset(WidthScale(-5))
            make.height.equalTo(WidthScale(24))
            make.width.equalTo(WidthScale(26))
        }
        
        cardView.addSubview(resolutionL)
        resolutionL.font = UIFont.systemFont(ofSize: WidthScale(12))
        resolutionL.textColor = Colors.whiteTextColor
        resolutionL.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(WidthScale(10))
            make.centerY.equalTo(collectBtn)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDidChange), name: NotificationName.TraitCollectionDidChange, object: nil)
    }
    
    @objc func darkModeDidChange(){
        contentView.layer.shadowColor = Colors.imageCellShadowColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func trashBtnAction(){
        trashBtn.isEnabled = false
        let generator = UINotificationFeedbackGenerator()
        
        if SQLManager.deleteFromHistoryTable(model) <= 0{
            UIView.makeToast("历史记录删除失败")
            generator.notificationOccurred(.error)
        }else{
            generator.notificationOccurred(.success)
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationName.HistoryRecordDeleted), object: nil, userInfo: ["cell": self])
        }
        
        trashBtn.isEnabled = true
    }
    
    @objc func collectBtnAction(){
        collectBtn.isEnabled = false
        let generator = UINotificationFeedbackGenerator()
        
        if collectBtn.isSelected{
            if SQLManager.deleteFromCollection(model) <= 0{
                UIView.makeToast("收藏夹删除失败")
                generator.notificationOccurred(.error)
            }else{
                generator.notificationOccurred(.success)
                collectBtn.isSelected = false
                model.isCollected = false
            }
        }else{
            if SQLManager.insertCollection(model) <= 0{
                UIView.makeToast("加入收藏夹失败")
                generator.notificationOccurred(.error)
            }else{
                generator.notificationOccurred(.success)
                collectBtn.isSelected = true
                model.isCollected = true
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationName.CollectionStateChaged), object: nil, userInfo: ["cell": self])
        collectBtn.isEnabled = true
    }
    
}
