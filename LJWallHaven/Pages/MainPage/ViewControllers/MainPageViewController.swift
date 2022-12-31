//
//  MainPageViewController.swift
//  LJWallHaven
//  主页控制器
//  Created by 唐星宇 on 2021/2/23.
//

import UIKit
import YYKit

class MainPageTabBarController: UITabBarController{
    
    let pictureFlowVC: PictureFlowViewController = PictureFlowViewController()
    
    var pictureFlowNavVC: UINavigationController!
    
    let settingVC: SettingViewController = SettingViewController()
    
    var settingNavVC: UINavigationController!
    
    let categoryVC: CategoryViewController = CategoryViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barStyle = .default
        
        pictureFlowNavVC = UINavigationController(rootViewController: pictureFlowVC)
        pictureFlowNavVC.navigationBar.barStyle = .black
        pictureFlowNavVC.tabBarItem.image = UIImage(systemName: "house")
        pictureFlowNavVC.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        pictureFlowNavVC.tabBarItem.title = "主页"
        
        categoryVC.tabBarItem.image = UIImage(systemName: "square.grid.2x2")
        categoryVC.tabBarItem.selectedImage = UIImage(systemName: "square.grid.2x2.fill")
        categoryVC.tabBarItem.title = "热门分类"
        
        settingNavVC = UINavigationController(rootViewController: settingVC)
        settingNavVC.tabBarItem.image = UIImage(systemName: "ellipsis.circle")
        settingNavVC.tabBarItem.selectedImage = UIImage(systemName: "ellipsis.circle.fill")
        settingNavVC.tabBarItem.title = "更多"
        
        setViewControllers([pictureFlowNavVC, categoryVC, settingNavVC], animated: true)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let collection = previousTraitCollection{
            userInterfaceStyle = collection.userInterfaceStyle
            NotificationCenter.default.post(name: NotificationName.TraitCollectionDidChange, object: nil)
        }
        
    }
    
}
