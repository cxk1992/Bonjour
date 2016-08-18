//
//  ViewController.swift
//  Bonjour
//
//  Created by 陈旭珂 on 2016/8/16.
//  Copyright © 2016年 陈旭珂. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextFieldDelegate {
    
    var handler : ConnectHandler?{
        didSet{
            handler?.dataReceiveClouser = { (data:Data ,handler:ConnectHandler) in
                let message = String(data: data, encoding: String.Encoding.utf8)
                let messageh = Message()
                messageh.type = .fromOther
                messageh.message = message
                self.dataSource.append(messageh)
                self.tableView.reloadData()
            }
            self.dataSource = (handler?.messages)!
            self.tableView.reloadData()
        }
    }
    
    var name = "viewController"{
        didSet{
            titleLabel.text = name
        }
    }
    
    var dataSource : [Message] = []
    
    let tableView = UITableView(frame: CGRect(), style: .plain)
    
    let textField = UITextField()
    
    let titleLabel = { () -> UILabel in
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        titleLabel.frame = CGRect(x: 0, y: 20, width: view.bounds.size.width, height: 30)
        titleLabel.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.addSubview(titleLabel)
        
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 50, width: view.bounds.size.width, height: view.bounds.size.height - 80)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        textField.frame = CGRect(x: 0, y: view.bounds.size.height - 50, width: view.bounds.size.width, height: 30)
        textField.autoresizingMask = [.flexibleTopMargin,.flexibleWidth]
        textField.delegate = self
        textField.borderStyle = .roundedRect
        view.addSubview(textField)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        if textField.text?.characters.count != 0{
            handler?.send(data: (textField.text?.data(using: .utf8))!)
            
            let message = Message()
            message.message = textField.text
            self.dataSource.append(message)
            self.tableView.reloadData()
            
            textField.text = ""
        }
        textField.resignFirstResponder()
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
    }
    
    deinit {
        print(#function)
    }

}

extension ViewController : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell?.detailTextLabel?.textColor = .black
            cell?.textLabel?.textColor = .black
        }
        let message = dataSource[indexPath.row]
        
        if message.type == .fromOther {
            cell?.textLabel?.text = message.message
        }else{
            cell?.detailTextLabel?.text = message.message
        }
        
        
        return cell!
    }
}

