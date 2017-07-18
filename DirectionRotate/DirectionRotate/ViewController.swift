//
//  ViewController.swift
//  DirectionRotate
//
//  Created by ShoIto on 2016/07/29.
//  Copyright © 2016年 ShoIto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let rotationView = DirectionRotateView.instance()
    
    let label = UILabel(frame: CGRectMake(100, 500, 100, 100))
    let screenFrame = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //
        rotationView.frame = CGRectMake(screenFrame.width - 300,
                                        screenFrame.height - 300,
                                        200,
                                        200)
        rotationView.delegate = self
        view.addSubview(rotationView)
        
        label.text = "0"
        view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - DirectionRotateViewDelegate
extension ViewController: DirectionRotateViewDelegate {
    func directionRotateView(directionRotateViewController: DirectionRotateView, didDesideDirection direction: CGFloat) {
        label.text = direction.description
    }
}

