//
//  PinView.swift
//  PinMarkMove
//
//  Created by ShoIto on 2016/06/09.
//  Copyright © 2016年 ShoIto. All rights reserved.
//

import UIKit

@objc enum Shape: Int {
    case circle
    case triangle
    case revTriangle
    case square
    case star
    case hexagram
}

private let defaultSize: CGFloat = 44.0

func radian(fromAngle fromAngle: CGFloat) -> CGFloat {
    return fromAngle * CGFloat(M_PI) / 180.0
}

class PinView: UIView {
    
    override var frame: CGRect {
        didSet {
            updateSize()
        }
    }

    func updateSize() {
        size = min(frame.width, frame.height)
        harfSize = size / 2.0
        quarterSize = size / 4.0
    }
    
    private var size: CGFloat = 0.0
    private var harfSize: CGFloat = 0.0
    private var quarterSize: CGFloat = 0.0
    
    // MARK: - Initilize
    init(point: CGPoint, size: CGFloat = defaultSize, shape: Shape) {
        let rect = CGRectMake(point.x, point.y, size, size)
        super.init(frame: rect)
        
        updateSize()
        // サイズに基づいて形変更
        changeShape(shape, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Method
    private func resetShape() {
        // 円形初期化
        layer.cornerRadius = 0
        // 三角形、星、六芒星初期化
        layer.mask?.removeFromSuperlayer()
    }
    
    // 正円形(○)
    private func shapeCircle() {
        // 形を正円に成形
        layer.cornerRadius = size / 2
    }
    
    // 三角形(△)
    private func shapeTriangle() {
        // パスで三角形をつくる
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, size)
        CGPathAddLineToPoint(path, nil, harfSize, 0)
        CGPathAddLineToPoint(path, nil, size, size)
        CGPathAddLineToPoint(path, nil, 0, size)
        CGPathCloseSubpath(path)
        // 三角形用のマスクを生成と適用
        let mask = CAShapeLayer()
        mask.frame = layer.bounds
        mask.path = path
        layer.mask = mask
    }
    
    // 逆三角形(▽)
    private func shapeRevTriangle() {
        // パスで三角形をつくる
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, size, 0)
        CGPathAddLineToPoint(path, nil, harfSize, size)
        CGPathAddLineToPoint(path, nil, 0, 0)
        CGPathCloseSubpath(path)
        
        // 三角形用のマスクを生成と適用
        let mask = CAShapeLayer()
        mask.frame = layer.bounds
        mask.path = path
        layer.mask = mask
    }
    
    // 四角形(□)
    private func shapeSquare() {
        // 処理なし
    }
    
    // 星型(☆)
    private func shapeStar() {
        // 座標計算用のラジアン
        let upperRadian = radian(fromAngle: 18)
        let lowerRadian = radian(fromAngle: -54)
        // 座標計算
        let upperPoint = CGPointMake(harfSize * cos(upperRadian), harfSize * sin(upperRadian))
        let lowerPoint = CGPointMake(harfSize * cos(lowerRadian), harfSize * sin(lowerRadian))
        
        // パスで星をつくる
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, harfSize - upperPoint.x, harfSize - upperPoint.y)
        CGPathAddLineToPoint(path, nil, harfSize + upperPoint.x, harfSize - upperPoint.y)
        CGPathAddLineToPoint(path, nil, harfSize - lowerPoint.x, harfSize - lowerPoint.y)
        CGPathAddLineToPoint(path, nil, harfSize, 0)
        CGPathAddLineToPoint(path, nil, harfSize + lowerPoint.x, harfSize - lowerPoint.y)
        CGPathAddLineToPoint(path, nil, harfSize - upperPoint.x, harfSize - upperPoint.y)
        CGPathCloseSubpath(path)
        
        // 星用のマスクを生成と適用
        let mask = CAShapeLayer()
        mask.frame = layer.bounds
        mask.path = path
        layer.mask = mask
    }
    
    // 六芒星(✡)
    private func shapeHexagram() {
        // 座標の計算
        let distance = sqrt(pow(harfSize, 2) - pow(quarterSize, 2))
        
        let triPoint1 = CGPointMake(harfSize - distance, quarterSize)
        let triPoint2 = CGPointMake(harfSize + distance, quarterSize)
        let triPoint3 = CGPointMake(harfSize, size)
        let revTriPoint1 = CGPointMake(harfSize, 0)
        let revTriPoint2 = CGPointMake(harfSize + distance, quarterSize * 3)
        let revTriPoint3 = CGPointMake(harfSize - distance, quarterSize * 3)
        
        // △のパスを作る
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, triPoint1.x, triPoint1.y)
        CGPathAddLineToPoint(path, nil, triPoint2.x, triPoint2.y)
        CGPathAddLineToPoint(path, nil, triPoint3.x, triPoint3.y)
        CGPathAddLineToPoint(path, nil, triPoint1.x, triPoint1.y)
        CGPathCloseSubpath(path)
        // ▽のパスを作る
        CGPathMoveToPoint(path, nil, revTriPoint1.x, revTriPoint1.y)
        CGPathAddLineToPoint(path, nil, revTriPoint2.x, revTriPoint2.y)
        CGPathAddLineToPoint(path, nil, revTriPoint3.x, revTriPoint3.y)
        CGPathAddLineToPoint(path, nil, revTriPoint1.x, revTriPoint1.y)
        CGPathCloseSubpath(path)
        
        // 六芒星用のマスクを生成と適用
        let mask = CAShapeLayer()
        mask.frame = layer.bounds
        mask.path = path
        layer.mask = mask
    }
    
    // MARK: - Instance Method
    func changeShape(shape: Shape, size: CGFloat? = nil) {
        // サイズ変更
        if let size = size {
            frame.size = CGSizeMake(size, size)
        }
        
        // 形をリセット
        resetShape()
        
        switch shape {
        case .circle:
            shapeCircle()
        case .triangle:
            shapeTriangle()
        case .revTriangle:
            shapeRevTriangle()
        case .square:
            shapeSquare()
        case .star:
            shapeStar()
        case .hexagram:
            shapeHexagram()
        }
    }
    
    // instanceを移動
    func move(transfer: Transfer) {
        frame = transfer.apply(to: frame)
    }
}
