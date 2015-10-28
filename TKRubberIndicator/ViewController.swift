//
//  ViewController.swift
//  TKRubberIndicator
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015年 TBXark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor(red:0.553,  green:0.376,  blue:0.549, alpha:1)
        let page = TKRubberIndicator(frame: CGRectMake(100, 100, 200, 100), count: 5)
        page.center = self.view.center
        page.valueChange = {(num) -> Void in
            print("Closure : Page is \(num)")
        }
        page.addTarget(self, action: "targetActionValueChange:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(page)
    }
    
    func targetActionValueChange(page:TKRubberIndicator){
        print("Target-Action : Page is \(page.currentIndex)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

}

