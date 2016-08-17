//
//  MenuTableViewController.swift
//  Bonjour
//
//  Created by 陈旭珂 on 2016/8/16.
//  Copyright © 2016年 陈旭珂. All rights reserved.
//

import UIKit

enum NetStatus : String {
    case none
    case publish
    case search
}

class MenuTableViewController: UITableViewController {
    
    var dataSource = []
    
    var pulishItem : UIBarButtonItem?
    var searchItem : UIBarButtonItem?
    
    var titleName:String = ""{
        didSet{
            title = titleName
        }
    }
    var status : NetStatus = .none{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    let serviceBrowser = NetServiceBrowser()
    var foundService:[NetService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup(){
        pulishItem = UIBarButtonItem(title: "发布", style: .done, target: self, action: #selector(publishAction))
        searchItem = UIBarButtonItem(title: "搜索", style: .done, target: self, action: #selector(MenuTableViewController.searchAction))
        navigationItem.rightBarButtonItems = [pulishItem!,searchItem!]
    }
    
    // MARK: click
    
    @objc func publishAction(item : UIBarButtonItem){
        if item.title != "stop" {
            searchItem?.isEnabled = false
            item.title = "stop"
            ServerManager.defaultManager.publishService(connectClouser: { (handler) in
                
            })
            status = .publish
            
        }else{
            searchItem?.isEnabled = true
            item.title = "发布"
            ServerManager.defaultManager.closeService()
            status = .none
        }
    }
    
    @objc func searchAction(item : UIBarButtonItem){
        if item.title != "stop" {
            pulishItem?.isEnabled = false
            item.title = "stop"
            status = .search
            serviceBrowser.delegate = self
            serviceBrowser.searchForServices(ofType: serviceType, inDomain: "")
        }else{
            pulishItem?.isEnabled = true
            item.title = "搜索"
            status = .none
            serviceBrowser.stop()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }

    let cellId = "cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        }
        
        cell?.textLabel?.text = "cell : \(indexPath.row)"
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ViewController()
        viewController.name = "cell : \(indexPath.row)"
        let vcs = splitViewController?.viewControllers
        for idx in 0..<(vcs?.count)!{
            if vcs?[idx] == navigationController{
                print("find the menu controller \(idx)")
            }
        }
        splitViewController?.showDetailViewController(viewController, sender: nil)
    }
}

extension MenuTableViewController : NetServiceBrowserDelegate{
    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser){
        print(#function)
        foundService.removeAll()
    }
    
    
    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser){
        print(#function)
    }
    
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]){
        print(#function)
    }
    
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool){
        print(#function)
    }
    
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool){
        print(#function)
        foundService.append(service)
    }
    
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool){
        print(#function)
    }
    
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool){
        print(#function)
        
        let index = foundService.index(where: { (someService) -> Bool in
            return service.name == someService.name
        })
        if index == NSNotFound {
            print("found error")
        }else{
            foundService.remove(at: index!)
        }
    }
}
