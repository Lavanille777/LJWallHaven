//
//  LJNavigationBar.swift
//  LearnJapanese
//
//  Created by 唐星宇 on 2020/7/22.
//  Copyright © 2020 唐星宇. All rights reserved.
//

import UIKit

class LJNavigationBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(blurView)
        blurView.effect = UIBlurEffect(style: .systemMaterial)
        blurView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        blurView.contentView.addSubview(bottomLine)
        bottomLine.backgroundColor = Colors.navLineColor
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("初始化失败")
    }
    
    var blurView: UIVisualEffectView = UIVisualEffectView()
    
    /// 导航标题
    lazy var navTitleL:UILabel = {
        let nTitle = UILabel.init()
        nTitle.textAlignment = .center
        nTitle.font = UIFont.boldSystemFont(ofSize: WidthScale(16))
        nTitle.textColor = Colors.whiteTextColor
        return nTitle
    }()
    
    // MARK: - PRIVAE
    lazy var leftBtn:UIButton = {
        let bBtn = UIButton.init(type: .custom)
        return bBtn
    }()
    
    lazy var rightBtn:UIButton = {
        let rBtn = UIButton.init(type: .custom)
        return rBtn
    }()
    
    var bottomLine: UIView = UIView()

}
