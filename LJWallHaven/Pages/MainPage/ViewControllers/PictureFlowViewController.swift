//
//  PictureFlowViewController.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/5.
//

import UIKit
import SDWebImage
import MJRefresh
import JXPhotoBrowser
import NVActivityIndicatorView

class PictureFlowViewController: LJBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, PictureFlowCollectionFlowLayoutDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var searchHintBGV: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    
    var searchHintTableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    lazy var pictureCollectionView:UICollectionView = {
        
        let flowLayout = PictureFlowCollectionFlowLayout.init()
        flowLayout.minimumLineSpacing = WidthScale(10)
        flowLayout.minimumInteritemSpacing = WidthScale(10)
        flowLayout.sectionInset = UIEdgeInsets(top: NavPlusStatusH + WidthScale(10), left: WidthScale(10), bottom: TabBarPlusBH, right: WidthScale(10))
        flowLayout.scrollDirection = .vertical
        flowLayout.delegate = self
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
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
    
    var macroDataArr: [SearchMacroModel] = []
    
    var dataArr: [WallpaperInfoModel] = []
    
    var searchTextFiled: LJTextFiled = LJTextFiled()
    
    var searchParameters: String = ""
    
    var emptyResultView: EmptyResultView = EmptyResultView()
    
    var pictureFilterView: PictureFilterView = PictureFilterView()
    
    var filterBtn: UIButton = UIButton()
    
    var homeBtn: UIButton = UIButton()
    
    var cellPlusImageV: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        loadNewData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionStateChagedAction), name: Notification.Name(NotificationName.CollectionStateChaged), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func CollectionStateChagedAction(noti: Notification){
        if let userInfo = noti.userInfo,
           let cell = userInfo["cell"] as? PictureFlowCollectionViewCell{
            for model in dataArr{
                if model.id == cell.model.id{
                    model.isCollected = cell.model.isCollected
                }
            }
            pictureCollectionView.reloadData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.pictureCollectionView.reloadData()
        }
    }
    
    func setUpUI(){
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(selfViewTapAction))
        tapGes.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGes)
        
        view.addSubview(pictureCollectionView)
        pictureCollectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.searchImg()
        })
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
        emptyResultView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        
        createNavbar(navTitle: "每日推荐", leftIsImage: false, leftStr: nil, rightIsImage: false, rightStr: nil, leftAction: nil, ringhtAction: nil)
        
        navgationBarV.leftBtn.addTarget(self, action: #selector(searchBtnAction), for: .touchUpInside)
        navgationBarV.leftBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        
        searchTextFiled.alpha = 0
        searchTextFiled.textFiled.textColor = Colors.whiteTextColor
        searchTextFiled.textFiled.keyboardType = .webSearch
        searchTextFiled.textFiled.addTarget(self, action: #selector(searchImg), for: .editingDidEndOnExit)
        searchTextFiled.textFiled.addTarget(self, action: #selector(textFiledValueChanged), for: .editingChanged)
        searchTextFiled.cancelSearchBtn.addTarget(self, action: #selector(clearTextFiled), for: .touchUpInside)
        navgationBarV.addSubview(searchTextFiled)
        searchTextFiled.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(WidthScale(0))
            make.height.equalTo(WidthScale(35))
            make.bottom.equalToSuperview().inset(WidthScale(5))
        }
        
        navgationBarV.addSubview(filterBtn)
        filterBtn.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        filterBtn.tintColor = Colors.whiteTextColor
        filterBtn.addTarget(self, action: #selector(filterBtnAction), for: .touchUpInside)
        filterBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: WidthScale(35), height: WidthScale(35)))
            make.right.equalToSuperview().inset(WidthScale(10))
            make.centerY.equalTo(navgationBarV.navTitleL)
        }
        
        navgationBarV.addSubview(homeBtn)
        homeBtn.tag = 0
        homeBtn.setImage(UIImage(systemName: "house"), for: .normal)
        homeBtn.tintColor = Colors.whiteTextColor
        homeBtn.addTarget(self, action: #selector(homeBtnAction), for: .touchUpInside)
        homeBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: WidthScale(35), height: WidthScale(35)))
            make.right.equalTo(filterBtn.snp.left)
            make.centerY.equalTo(navgationBarV.navTitleL)
        }
        
        view.addSubview(searchHintBGV)
        searchHintBGV.alpha = 0
        searchHintBGV.snp.makeConstraints { (make) in
            make.top.equalTo(navgationBarV.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        
        pictureFilterView.isHidden = true
        
        searchHintBGV.contentView.addSubview(searchHintTableView)
        searchHintTableView.backgroundColor = .clear
        searchHintTableView.delegate = self
        searchHintTableView.dataSource = self
        searchHintTableView.separatorStyle = .none
        searchHintTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    @objc func filterBtnAction(){
        if pictureFilterView.isHidden{
            pictureFilterView.show()
        }else{
            pictureFilterView.hide()
        }
        
    }
    
    @objc func homeBtnAction(){
        if homeBtn.tag == 0{
            searchTextFiled.placeHolder.isHidden = false
            searchTextFiled.textFiled.text = ""
        }
        searchImg()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return macroDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SettingVCCell")
        
        cell.textLabel?.text = macroDataArr[indexPath.row].key
        cell.textLabel?.textColor = Colors.whiteTextColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: WidthScale(14))
        cell.backgroundColor = .clear
        cell.detailTextLabel?.textColor = HEXCOLOR(h: 0x949494, alpha: 1.0)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(settingVCCellLongPressAction))
        longPress.name = macroDataArr[indexPath.row].value
        longPress.minimumPressDuration = 0.7
        cell.addGestureRecognizer(longPress)
        cell.selectionStyle = .none
        cell.detailTextLabel?.textColor = Colors.detailTextColor
        cell.detailTextLabel?.text = macroDataArr[indexPath.row].value
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: WidthScale(14))
        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        imageView.tintColor = .green
        cell.accessoryView = imageView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextFiled.textFiled.text?.append(" \(macroDataArr[indexPath.row].value)")
        searchTextFiled.placeHolder.isHidden = searchTextFiled.textFiled.text != ""
    }
    
    @objc func clearTextFiled(){
        searchTextFiled.textFiled.text = ""
        searchTextFiled.placeHolder.isHidden = false
    }
    
    @objc func searchImg(isLike: Bool = false){
        
        searchParameters = searchTextFiled.textFiled.text ?? ""
        
        if isLike{
            searchParameters = "like:\(searchParameters)"
        }
        
        cancelSearchAction()
        
        UIView.startLoading()
        
        WallPaperInfoManager.shared.searchWallpaper(ByTag: searchParameters, isAuthentic: true) { (models, error) in
            UIView.stopLoading()
            if self.searchParameters.count > 0{
                self.navgationBarV.navTitleL.text = self.searchParameters
            }else{
                self.navgationBarV.navTitleL.text = "每日推荐"
            }
            if isLike{
                self.navgationBarV.navTitleL.text = "相关的图"
            }
            
            if self.searchParameters.contains("id:"){
                for (title, id) in categoryTitleArr{
                    let subString = self.searchParameters[self.searchParameters.index(self.searchParameters.startIndex, offsetBy: 3)..<self.searchParameters.endIndex]
                    if subString == "\(id)"{
                        self.navgationBarV.navTitleL.text = title
                    }
                }
            }
            
            if let error = error{
                Dprint(error)
            }
            self.pictureCollectionView.mj_footer?.endRefreshing()
            self.pictureCollectionView.mj_header?.endRefreshing()
            if let models = models{
                self.pictureCollectionView.mj_footer?.isHidden = false
                self.dataArr = models
                pageSize = models.count
            }else{
                self.pictureCollectionView.mj_footer?.isHidden = true
                self.dataArr = []
            }
            
            self.pictureCollectionView.contentOffset = CGPoint(x: 0, y: 0)
            self.pictureCollectionView.reloadData()
            
            self.emptyResultView.isHidden = models?.count ?? 0 > 0
            self.pictureCollectionView.mj_footer?.isHidden = models?.count ?? 0 == 0
            
        }
    }
    
    @objc func settingVCCellLongPressAction(ges: UILongPressGestureRecognizer){
        if ges.state == .began{
            if let name = ges.name{
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = name
                UIView.makeToast("\(name) 已复制到剪贴板")
            }
        }
    }
    
    @objc func selfViewTapAction(ges: UITapGestureRecognizer){
        let point = ges.location(in: view)
        if !searchTextFiled.frame.contains(point) && !navgationBarV.leftBtn.frame.contains(point){
            hideKeyboard()
        }
    }
    
    @objc func cancelSearchAction(){
//        searchTextFiled.textFiled.text = ""
//        searchTextFiled.placeHolder.isHidden = false
        homeBtn.tag = 0
        homeBtn.setImage(UIImage(systemName: "house") , for: .normal)
        navgationBarV.leftBtn.setImage(UIImage(systemName: "magnifyingglass") , for: .normal)
        hideKeyboard()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.searchTextFiled.alpha = 0
            self.navgationBarV.navTitleL.alpha = 1
            self.searchHintBGV.alpha = 0
            self.searchTextFiled.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.width.equalTo(WidthScale(0))
                make.height.equalTo(WidthScale(35))
                make.bottom.equalToSuperview().inset(WidthScale(5))
            }
            self.searchHintBGV.snp.remakeConstraints { (make) in
                make.top.equalTo(self.navgationBarV.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(WidthScale(0))
            }
            self.view.layoutIfNeeded()
        } completion: { (completed) in
            
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

    }
    
    func loadNewData(){
        UIView.startLoading()
        WallPaperInfoManager.shared.searchWallpaper(isAuthentic: false) { (models, error) in
            UIView.stopLoading()
            if let error = error{
                Dprint(error)
            }
            self.pictureCollectionView.mj_footer?.endRefreshing()
            self.pictureCollectionView.mj_header?.endRefreshing()
            if let models = models{
                self.pictureCollectionView.mj_footer?.isHidden = false
                self.dataArr = models
                pageSize = models.count
                self.pictureCollectionView.reloadData()
            }
            self.emptyResultView.isHidden = true
        }
    }
    
    func loadMoreData(){
        WallPaperInfoManager.shared.searchWallpaper(ByTag: searchParameters, page: dataArr.count / pageSize + 1, isAuthentic: false) { (models, error) in
            if let error = error{
                Dprint(error)
            }
            self.pictureCollectionView.mj_footer?.endRefreshing()
            self.pictureCollectionView.mj_header?.endRefreshing()
            if let models = models{
                self.pictureCollectionView.mj_footer?.isHidden = models.count < pageSize
                self.dataArr.append(contentsOf: models)
                self.pictureCollectionView.reloadData()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureFlowCollectionViewCell", for: indexPath) as! PictureFlowCollectionViewCell
        cell.model = dataArr[indexPath.item]
        cell.collectBtn.isSelected = cell.model.isCollected
        if let url = URL(string: dataArr[indexPath.item].thumbs[.original] ?? ""){
            cell.imageView.setImageWith(url, options: [.setImageWithFadeAnimation])
            cell.contentView.layoutIfNeeded()
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
            
            cell.resolutionL.text = dataArr[indexPath.item].resolution
            cell.sizeL.text = String(format: "大小: %.2fMB", Double(dataArr[indexPath.item].file_size) / 1024.0 / 1024.0)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.global().async {
            if SQLManager.insertBrowseHistory(self.dataArr[indexPath.item]) <= 0 {
                Dprint("插入历史浏览数据库失败")
            }
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PictureFlowCollectionViewCell, cell.imageView.image != nil else {
            return
        }
        
        let imgBrowser: LJPhotoBrowser = LJPhotoBrowser()
        imgBrowser.pictureFlowViewController = self
        imgBrowser.placeHolderImg = cell.imageView.image
        imgBrowser.model = dataArr[indexPath.item]
        imgBrowser.delegateCell = cell
        imgBrowser.numberOfItems = {
            1
        }
        
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboard()

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
    
    func setCellHeights(indexPath: IndexPath) -> CGFloat {
        return dataArr[indexPath.item].dimension.y / dataArr[indexPath.item].dimension.x * WidthScale(172.5) + WidthScale(64)
    }
    
    @objc func textFiledValueChanged(){
//        macroDataArr = SQLManager.querySearchMacro(byKey: searchTextFiled.textFiled.text ?? "")
//        searchHintTableView.reloadData()
    }
    
    @objc func searchBtnAction(){
        if !pictureFilterView.isHidden{
            pictureFilterView.hide()
        }
        
        if searchTextFiled.alpha > 0{
            cancelSearchAction()
        } else {
            homeBtn.tag = 1
            homeBtn.setImage(UIImage(systemName: "magnifyingglass") , for: .normal)
            navgationBarV.leftBtn.setImage(UIImage(systemName: "arrowshape.turn.up.left") , for: .normal)
            
            searchTextFiled.isHidden = false
            searchTextFiled.alpha = 0
            DispatchQueue.global().async {
                self.macroDataArr = SQLManager.queryAllSearchMacro() ?? []
                
                if self.macroDataArr.count == 0{
                    let model4 = SearchMacroModel()
                    model4.key = "只能搜索英文哦"
                    model4.value = "moon"
                    let model1 = SearchMacroModel()
                    model1.key = "这些是搜索宏，可以帮助你搜索"
                    model1.value = "sky"
                    let model3 = SearchMacroModel()
                    model3.key = "单击填充到搜索框，长按复制"
                    model3.value = "stars"
                    let model7 = SearchMacroModel()
                    model7.key = "可在图片详细信息里点击标签来添加搜索宏"
                    model7.value = "city"
                    let model = SearchMacroModel()
                    model.key = "也可在设置中添加搜索宏"
                    model.value = "sea"
                    let model5 = SearchMacroModel()
                    model5.key = "可以用空格组合"
                    model5.value = "house"
                    let model6 = SearchMacroModel()
                    model6.key = "例如点击搜索本条得到的图都包含人和山"
                    model6.value = "people mountain"
                    self.macroDataArr.append(contentsOf: [model4, model1,model3, model7,model, model5, model6])
                }
                DispatchQueue.main.async {
                    self.searchHintTableView.reloadData()
                }
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.searchTextFiled.alpha = 1
                self.navgationBarV.navTitleL.alpha = 0
                self.searchHintBGV.alpha = 1
                self.searchTextFiled.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.navgationBarV.leftBtn.snp.right).offset(-WidthScale(10))
                    make.width.equalTo(WidthScale(240))
                    make.height.equalTo(WidthScale(35))
                    make.bottom.equalToSuperview().inset(WidthScale(5))
                }
                
                self.searchHintBGV.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.navgationBarV.snp.bottom)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(SCREEN_HEIGHT - NavPlusStatusH - TabBarPlusBH)
                }
                self.view.layoutIfNeeded()
            } completion: { (completed) in
                
            }
        }
    }
    
}


class LJTextFiled: UIView {
    
    var textFiled: UITextField = UITextField()
    
    var placeHolder: UILabel = UILabel()
    
    var cancelSearchBtn: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        self.layer.borderWidth = 1
        self.layer.borderColor = HEXCOLOR(h: 0xdf9464, alpha: 1.0).cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = WidthScale(8)
        
        addSubview(textFiled)
        textFiled.textColor = Colors.whiteTextColor
        textFiled.font = UIFont.systemFont(ofSize: WidthScale(16))
        textFiled.addTarget(self, action: #selector(textFiledValueChanged), for: .editingChanged)
        textFiled.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(WidthScale(10))
            make.right.equalToSuperview().inset(WidthScale(25))
            make.centerY.equalToSuperview()
        }
        
        addSubview(placeHolder)
        placeHolder.text = "请输入英文关键词(可用空格组合)"
        placeHolder.font = UIFont.systemFont(ofSize: WidthScale(12))
        placeHolder.textColor = HEXCOLOR(h: 0xdf9464, alpha: 1.0)
        placeHolder.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(WidthScale(10))
        }
        
        addSubview(cancelSearchBtn)
        cancelSearchBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelSearchBtn.tintColor = Colors.whiteTextColor
        cancelSearchBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(WidthScale(30))
        }
        
    }
    
    @objc func textFiledValueChanged(){
        placeHolder.isHidden = textFiled.text?.count ?? 0 > 0
    }
    
}

