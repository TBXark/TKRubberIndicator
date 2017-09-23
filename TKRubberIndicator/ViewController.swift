//
//  ViewController.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015年 TBXark. All rights reserved.
//

import UIKit
import TKRubberPageControl

class ViewController: UIViewController {

    let page = TKRubberPageControl(frame: CGRect(x: 100, y: 100, width: 200, height: 100), count: 3)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.backgroundColor = UIColor.white
        page.center = view.center
        page.valueChange = {(num) -> Void in
            print("Closure : Page is \(num)")
        }
        page.addTarget(self, action: #selector(ViewController.targetActionValueChange(_:)), for: UIControlEvents.valueChanged)
        view.addSubview(page)


        page.numberOfpage = 3
    }
    
    @IBAction func pageCountChange(_ sender: UISegmentedControl) {
        page.numberOfpage = sender.selectedSegmentIndex + 3
    }
    @objc func targetActionValueChange(_ page:TKRubberPageControl){
        print("Target-Action : Page is \(page.currentIndex)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

}

