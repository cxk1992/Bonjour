//
//  ViewController.swift
//  Bonjour
//
//  Created by 陈旭珂 on 2016/8/16.
//  Copyright © 2016年 陈旭珂. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var name = "viewController"{
        didSet{
            titleLabel.text = name
        }
    }
    
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

