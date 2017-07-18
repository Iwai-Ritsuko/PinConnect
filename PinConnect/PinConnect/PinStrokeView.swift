//
//  PinStrokeView.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/14.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

// ピン連結線描画クラス

import UIKit

class PinStrokeView: UIView {
    init(begin: CGPoint, end: CGPoint, drawArea: CGSize) {
        let frame = CGRectMake(0, 0, drawArea.width, drawArea.height)
        super.init(frame: frame)
        UIGraphicsBeginImageContext(frame.size)
        let path = UIBezierPath()
        
        path.moveToPoint(CGPointMake(begin.x, begin.y))
        path.addLineToPoint(CGPointMake(end.x, end.y))
        path.closePath()
        path.lineWidth = 3.0
        UIColor.redColor().setStroke()
        path.stroke()
        
        layer.contents = UIGraphicsGetImageFromCurrentImageContext().CGImage
        UIGraphicsEndImageContext()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
