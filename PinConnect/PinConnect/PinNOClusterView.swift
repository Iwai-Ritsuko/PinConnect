//
//  PinNOClusterView.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/24.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

// ピンNO配置クラスター

import UIKit

@objc protocol PinNoClusterViewDelegate {
    func pinNOClusterWillEdit(clusterID: Int)
}

@objc enum NumberType: Int {
    case numberOnly
    case encircledNumber
}

class PinNOClusterView: UIView {
    var pinNumber = 0
    var pinNumberType: NumberType = .encircledNumber
    var connectPoint = CGPointZero
    var clusterID = 0
    var displayString = ""
    var location = CGRectZero   // PinNOClusterView自身の座標
    
    var delegate: PinNoClusterViewDelegate!
    var touched = false
    
    // ピン連結線の接続先のポイントを求める
    func calculateConnectPoint(to drawView: PinDrawView) {
        // drawViewのboundsを取得(drawViewを基準にしたframeを取得)
        let drawViewFrame = drawView.bounds
        
        // self.frameをdrawViewを起点にした値に変換する
        let selfFrame = drawView.convertRect(self.frame, fromView: self.superview)
        
        // self.centerをdrawViewを起点にした値に変換する
        var connectPoint = drawView.convertPoint(self.center, fromView: self.superview)

        // drawViewからみたselfの位置を求める
        let relation = drawViewFrame.positionRelation(to: selfFrame)
        
        let xAdjuster = self.frame.width / 2.0
        switch relation.horizon {
        case .left:
            connectPoint.x += xAdjuster
        case .right:
            connectPoint.x -= xAdjuster
        case .middle:
            break
        }
        
        let yAdjuster = self.frame.height / 2.0
        switch relation.vertical {
        case .top:
            connectPoint.y += yAdjuster
        case .bottom:
            connectPoint.y -= yAdjuster
        case .middle:
            break
        }
        
        self.connectPoint = connectPoint
    }
   
    // ピン番号の更新
    func updatePinNumber(pinNo: Int) {
        pinNumber = pinNo
        switch(pinNumberType) {
        case .numberOnly:
            displayString = String(pinNumber)
        case .encircledNumber:
            // 丸数字の文字コードが50までしかわからない。。。
            switch(pinNumber) {
            case 0...50:
                displayString = String.encircled(number: pinNumber)
            default:
                displayString = String(pinNumber)
            }
        }
        touched = false
        setNeedsDisplay()
    }
    
    func distanceTo(point: CGPoint) -> CGFloat {
        return connectPoint.distanceTo(point: point)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case 1...16:
                let cluster = touch.view as! PinNOClusterView
                if NSString(string: cluster.displayString).length > 0 {
                    touched = true
                    self.delegate.pinNOClusterWillEdit(cluster.clusterID)
                }
            default:
                break
            }
        }
    }

    // ピン番号描画
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    
        if NSString(string: displayString).length != 0 {
            let paragraph = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            let textFontAttributes = [
                NSFontAttributeName: UIFont.systemFontOfSize(20.0),
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSParagraphStyleAttributeName: paragraph
            ]
            let attString = NSAttributedString(string: displayString, attributes: textFontAttributes)
            let drawSize = attString.size()
            attString.drawInRect(CGRectMake(
                (rect.width - drawSize.width) / 2,
                (rect.height - drawSize.height) / 2,
                drawSize.width,
                drawSize.height))
        }
    }
    
    // ピン番号削除
    func deletePinNO() {
        touched = false
        delegate = nil
        displayString = ""
        clusterID = 0
        pinNumber = 0
        
        setNeedsDisplay()
    }
    
    // ピン配置入れ替えのためのSwapViewに対する座標セット
    func adjustLocation(baseView: UIView) {
        location = (superview?.convertRect(frame, toView: baseView))!
    }
    
    // ボーダーを点滅される。色を指定できるように作ってあり、PinNOClusterManagerからは赤を渡している
    func blinkBorderWithColor(color: UIColor) {
        let borderColorAnimation = CABasicAnimation.init(keyPath: "borderColor")
        borderColorAnimation.fromValue = color.CGColor
        borderColorAnimation.toValue = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor
        borderColorAnimation.duration = 0.5
        borderColorAnimation.autoreverses = true
        borderColorAnimation.repeatCount = .infinity
        borderColorAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        layer.addAnimation(borderColorAnimation, forKey: "borderColorAnimation1")
    }
    
    func stopBlinkBorder() {
        layer.removeAllAnimations()
    }
}
