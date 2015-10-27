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
//        let shape : TKBubbleCell = TKBubbleCell(frame: CGRectMake(100, 300, 30, 30))
//        self.view.layer.addSublayer(shape)
//        shape.positionChange(MoveDirection.right, radius: 60, duration: 4)
        
        
//        let shape = TKMainBubble()
//        self.view.layer.addSublayer(shape)
//        shape.positionChange(MoveDirection.right, point: CGPointMake(400, 300), duration: 10)
        
        self.view.backgroundColor = UIColor(red:0.553,  green:0.376,  blue:0.549, alpha:1)
        let page = TKRubberIndicator(frame: CGRectMake(100, 100, 200, 100), count: 5)
        page.center = self.view.center
        self.view.addSubview(page)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

}

