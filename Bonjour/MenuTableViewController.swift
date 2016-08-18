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
    
    var dataSource : [ConnectHandler] = []
    
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
                self.dataSource.append(handler)
                handler.name = "client"
                handler.dataReceiveClouser = {(data : Data, handler : ConnectHandler) in
                    handler.hasNewMessage = true
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
            })
            status = .publish
            
        }else{
            searchItem?.isEnabled = true
            item.title = "发布"
            ServerManager.defaultManager.closeService()
            self.dataSource.removeAll()
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
            self.dataSource.removeAll()
            serviceBrowser.stop()
            status = .none
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }

    let cellId = "cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)

        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellId)
        }
        
        let handler = dataSource[indexPath.row]
        
        cell?.textLabel?.text = handler.name
        cell?.detailTextLabel?.text = handler.hasNewMessage ? "new message" : ""
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let handler = dataSource[indexPath.row]
        if status == .search {
            handler.cennect()
        }
        let sessionController = splitViewController?.viewControllers[1] as! ViewController
        if let abc = sessionController.handler {
            if abc == handler{
                return
            }
            abc.dataReceiveClouser = {(data : Data, handler : ConnectHandler) in
                handler.hasNewMessage = true
                self.tableView.reloadData()
            }
        }
        handler.hasNewMessage = false
        sessionController.handler = handler
        self.tableView.reloadData()
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
        let handler = ConnectHandler()
        handler.service = service;
        handler.name = service.name
        handler.dataReceiveClouser = { (data : Data,handler : ConnectHandler) in
            handler.hasNewMessage = true
            self.tableView.reloadData()
        }
        dataSource.append(handler)
        self.tableView.reloadData()
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
            
        }
    }
}
