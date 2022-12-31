//
//  PictureFlowCollectionFlowLayout.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/5.
//

import UIKit

protocol PictureFlowCollectionFlowLayoutDelegate {
    func setCellHeights(indexPath: IndexPath) -> CGFloat
}

class PictureFlowCollectionFlowLayout: UICollectionViewFlowLayout {
    
    open var delegate : PictureFlowCollectionFlowLayoutDelegate?
    
    var deleteIndexPath: IndexPath?
    
    //行间距
    override var minimumLineSpacing: CGFloat{
        didSet{
            //设置item的宽度
            self.setUpItemWidth()
        }
    }
    
    //列间距
    override var minimumInteritemSpacing: CGFloat{
        didSet{
            //设置item的宽度
            self.setUpItemWidth()
        }
    }
    
    fileprivate var item_w : CGFloat = 0//item宽度
    //内边距
    override var sectionInset: UIEdgeInsets{
        didSet{
            //设置item的宽度
            self.setUpItemWidth()
        }
    }
    //列数，默认2
    var columnsNum = 2{
        didSet{
            //设置列高
            self.columnsHeightArray.removeAll()
            for _ in 0...self.columnsNum{
                //如果数量不对则全部设置为0
                self.columnsHeightArray.append(0)
            }
            //设置item的宽度
            self.setUpItemWidth()
        }
    }
    
    fileprivate var attrArray : [UICollectionViewLayoutAttributes] = []//属性数组
    fileprivate var columnsHeightArray : [CGFloat] = [0,0]//每列的高度
    
    //设置每一个item的属性
    func setAttrs() {
        guard let secNum = self.collectionView?.numberOfSections else {
            return
        }
        for i in 0...secNum-1{
            for i in 0...self.columnsNum - 1{
                self.columnsHeightArray[i] = self.getLongValue()
            }
            if let attri = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath.init(row: 0, section: i)){
                self.attrArray.append(attri)
            }
            guard let itemsNum = self.collectionView?.numberOfItems(inSection: i), itemsNum > 0 else {
                return
            }
            for j in 0...itemsNum - 1{
                self.attrArray.append(self.layoutAttributesForItem(at: IndexPath.init(row: j, section: i))!)
            }
        }
    }
    
    //获取最短列的索引
    func getShortesIndex() -> Int {
        var index = 0
        for i in 0...self.columnsNum - 1{
            if self.columnsHeightArray[index] > self.columnsHeightArray[i]{
                index = i
            }
        }
        return index
    }
    
    //获取最长列的值
    func getLongValue() -> CGFloat {
        var value : CGFloat = 0
        for i in 0...self.columnsNum - 1{
            if value < self.columnsHeightArray[i]{
                value = self.columnsHeightArray[i]
            }
        }
        return value
    }
    
    //设置每列的宽度
    func setUpItemWidth(){
        guard let collectionWidth = self.collectionView?.frame.size.width else {
            return
        }
        
        self.item_w = (collectionWidth - self.sectionInset.left - self.sectionInset.right - self.minimumInteritemSpacing * CGFloat((self.columnsNum - 1))) / CGFloat(self.columnsNum)
    }
    
    override var collectionViewContentSize: CGSize{
        get{
            return CGSize.init(width: SCREEN_WIDTH, height: self.getLongValue() + self.sectionInset.top + self.sectionInset.bottom)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    override func prepare() {
        super.prepare()
        attrArray.removeAll()
        columnsHeightArray = [0,0]
        self.setUpItemWidth()
        self.setAttrs()
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard itemIndexPath.row < attrArray.count else {
            return self.layoutAttributesForItem(at: itemIndexPath)!
        }
        
        return attrArray[itemIndexPath.row]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        
        if attributes == nil{
            attributes = self.layoutAttributesForItem(at: itemIndexPath)!
        }
        
        if deleteIndexPath == itemIndexPath{
            attributes?.alpha = 0
        }
        
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attr = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        let shortesIndex = self.getShortesIndex()
        let item_x = self.sectionInset.left + (self.item_w + self.minimumInteritemSpacing) * CGFloat(shortesIndex)
        let item_y = self.columnsHeightArray[shortesIndex] + self.sectionInset.top
        let item_h = self.delegate?.setCellHeights(indexPath: indexPath) ?? 0
        attr.frame = CGRect.init(x: item_x, y: item_y , width: self.item_w, height: item_h)
        
        //更新列高数组
        self.columnsHeightArray[shortesIndex] += (item_h + self.minimumLineSpacing)
        
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attrArray
    }
    
}
