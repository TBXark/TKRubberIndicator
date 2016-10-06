//
//  ViewController.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015年 TBXark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let page = TKRubberPageControl(frame: CGRect(x: 100, y: 100, width: 200, height: 100), count: 3)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor(red:0.553,  green:0.376,  blue:0.549, alpha:1)
        page.center = self.view.center
        page.valueChange = {(num) -> Void in
            print("Closure : Page is \(num)")
        }
        page.addTarget(self, action: #selector(ViewController.targetActionValueChange(_:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(page)


        page.numberOfpage = 3
    }
    
    @IBAction func pageCountChange(_ sender: UISegmentedControl) {
        page.numberOfpage = sender.selectedSegmentIndex + 3
    }
    func targetActionValueChange(_ page:TKRubberPageControl){
        print("Target-Action : Page is \(page.currentIndex)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

}

