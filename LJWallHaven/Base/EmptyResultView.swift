//
//  EmptyResultView.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/2.
//

import UIKit

class EmptyResultView: UIView {

    var titleL: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        titleL.textColor = HEXCOLOR(h: 0xdf9464, alpha: 1.0)
        titleL.font = UIFont.systemFont(ofSize: WidthScale(14))
        titleL.text = "找不到图片了:( "
        addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
}
