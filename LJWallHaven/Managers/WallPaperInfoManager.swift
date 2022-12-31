//
//  WallPaperInfoManager.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/4.
//

import UIKit
import SwiftyJSON

enum DataManagerError: Error {
    case failedRequest
    case invalidResponse
    case unknown
}

final class WallPaperInfoManager {

    private let baseURL: URL
    
    private let urlSession: URLSessionProtocol
    
    private var request: URLRequest
    
    private init(baseURL: URL, urlSession: URLSessionProtocol) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        
        request = URLRequest(url: baseURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
    }
    
    static let shared = WallPaperInfoManager.init(baseURL: API.baseUrl, urlSession: URLSession.shared)
    
    typealias GetWallPaperCompletionHandler = (WallpaperInfoModel?, Error?) -> Void
    
    typealias GetWallPapersCompletionHandler = ([WallpaperInfoModel]?, Error?) -> Void
    
    /// 通过id获取壁纸
    /// - Parameters:
    ///   - id: 壁纸id
    ///   - isAuthentic: 是否有AppKey验证
    ///   - completion: 完成回调
    func getWallpaperBy(
        id: String,
        isAuthentic: Bool = false,
        completion: @escaping GetWallPaperCompletionHandler){
        
        let url: URL = baseURL.appendingPathComponent("/w/\(id)")
        
        request.url = url
        
        if let appKey = UserDefaults.standard.value(forKey: Setting.appKey) as? String{
            request.setValue(appKey, forHTTPHeaderField: "X-API-Key")
        }
        
        urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                self.didFinishingGettingWallpaperInfo(data: data, response: response, error: error, completion: completion)
            }
        }.resume()
        
    }
    
    
    /// 通过标签或关键字模糊搜索图片
    /// - Parameters:
    ///   - tag: 标签或关键字
    ///   - isAuthentic: 是否验证
    ///   - completion: 完成回调
    func searchWallpaper(ByTag tag: String = "",
                         page: Int = 1,
                         isAuthentic: Bool = false,
                         isLike: Bool = false,
                         completion: @escaping GetWallPapersCompletionHandler) {
        var tag = tag
        
        if isLike{
            tag = "like:\(tag)"
        }
        
        let categories = UserDefaults.standard.value(forKey: SearchFilterSetting.categoriesKey) ?? ""
        let sorting = UserDefaults.standard.value(forKey: SearchFilterSetting.sortingKey) ?? ""
        let order = UserDefaults.standard.value(forKey: SearchFilterSetting.orderKey) ?? ""
        let purity = UserDefaults.standard.value(forKey: SearchFilterSetting.purityKey) ?? ""
        
        let url: URL = URL.initPercent(string: baseURL.absoluteString + "/search/?q=\(tag)&page=\(page)&categories=\(categories)&sorting=\(sorting)&order=\(order)&purity=\(purity)&colors=\(SearchFilterSetting.color)")
        
        request.url = url
        
        if let appKey = UserDefaults.standard.value(forKey: Setting.appKey) as? String{
            request.setValue(appKey, forHTTPHeaderField: "X-API-Key")
        }else{
            request.setValue(nil, forHTTPHeaderField: "X-API-Key")
        }
        
        urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                self.didFinishingGettingWallpapersInfo(data: data, response: response, error: error, completion: completion)
            }
        }.resume()
        
    }
    
    /// 获取单张壁纸请求完成
    /// - Parameters:
    ///   - data: 网络数据
    ///   - response: 响应
    ///   - error: 错误
    ///   - completion: 完成回调
    private func didFinishingGettingWallpaperInfo(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: GetWallPaperCompletionHandler){
        
        if let error = error{
            UIView.makeToast(error.localizedDescription)
            completion(nil, error)
        }
        else if let data = data,
                let response = response as? HTTPURLResponse{
            if response.statusCode == 200 {
                do {
                    let json = try JSON(data: data)["data"]
                    let wallpaperInfo = WallpaperInfoModel.getModelFrom(json: json)
                    completion(wallpaperInfo, nil)
                } catch let error {
                    UIView.makeToast(error.localizedDescription)
                    completion(nil, error)
                }
            }else{
                let str = JSON(data)["error"].stringValue
                switch str {
                case "Unauthorized":
                    UIView.makeToast("AppKey无效")
                default:
                    UIView.makeToast(str)
                }
                completion(nil, error)
            }
        }
        else{
            completion(nil, error)
        }
    }
    
    
    /// 获取多张壁纸请求完成
    /// - Parameters:
    ///   - data: 网络数据
    ///   - response: 响应
    ///   - error: 错误
    ///   - completion: 完成回调
    private func didFinishingGettingWallpapersInfo(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: GetWallPapersCompletionHandler){
        
        if let error = error{
            UIView.makeToast(error.localizedDescription)
            completion(nil, error)
        }
        else if let data = data,
                let response = response as? HTTPURLResponse{
            if response.statusCode == 200 {
                do {
                    let json = try JSON(data: data)["data"].arrayValue
                    var wallpaperArr: [WallpaperInfoModel] = []
                    for imgJson in json {
                        wallpaperArr.append(WallpaperInfoModel.getModelFrom(json: imgJson))
                    }
                    completion(wallpaperArr, nil)
                } catch let error {
                    print(error)
                    UIView.makeToast(error.localizedDescription)
                    completion(nil, error)
                }
            }else{
                let str = JSON(data)["error"].stringValue
                switch str {
                case "Unauthorized":
                    UIView.makeToast("AppKey无效")
                default:
                    UIView.makeToast(str)
                }
                completion(nil, error)
            }
        }
        else{
            completion(nil, error)
        }
    }
    
}
