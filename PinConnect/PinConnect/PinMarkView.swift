//
//  PinMarkView.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/10.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

// ピンマーク描画クラス

import UIKit

@objc enum MarkShape: Int {
    case circle
    case triangle
}

class PinMarkView: UIView {
    private let pinSize: CGFloat = 20.0
    private var sharp: MarkShape;
    
    init(point: CGPoint, sharp: MarkShape) {
        let frame = CGRect(center: point, size: CGSize(width: pinSize, height: pinSize))
        self.sharp = sharp
        super.init(frame: frame)
        updateShape()
        self.backgroundColor = .redColor()
    }
    
    func updateShape() {
        switch sharp {
        case .circle:
            layer.cornerRadius = pinSize / 2
            layer.mask = nil
            // TODO: 三角形のレイヤーを外す
            
        case .triangle:
            layer.cornerRadius = 0
            
            // 三角形つくる
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, 0, 0)
            CGPathAddLineToPoint(path, nil, frame.width, 0)
            CGPathAddLineToPoint(path, nil, frame.width / 2, frame.height)
            CGPathAddLineToPoint(path, nil, 0, 0)
            CGPathCloseSubpath(path)
            
            // 三角形用のマスク
            let mask = CAShapeLayer()
            mask.frame = layer.bounds
            mask.path = path
            layer.mask = mask
            
            // 適用
            let shape = CAShapeLayer()
            shape.frame = bounds
            shape.path = path
            shape.lineWidth = 1.0
            shape.fillColor = UIColor.clearColor().CGColor
            layer.insertSublayer(shape, atIndex: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
