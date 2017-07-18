//
//  PinDrawView.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/10.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

// ピン・連結線DrawView

import UIKit

class PinDrawView: UIImageView {
    var max = 0
    
    // ピンマークと連結線追加
    func addPinco(pinData: PinData, connectPoint: CGPoint) {
        // Mark
        drawPinMark(pinData)
        
        // 連結線
        drawConnection(pinData, connectPoint: connectPoint)
    }
    
    // ピンマーク描画
    private func drawPinMark(pinData: PinData) {
        // Mark
        let sharp: MarkShape
        if pinData.photo == nil {
            sharp = .circle
        } else {
            sharp = .triangle
        }
        
        let pin: PinMarkView = PinMarkView(point: pinData.position, sharp: sharp)
        pin.tag = pinData.number
        addSubview(pin)
    }
    
    // 連結線描画
    private func drawConnection(pinData: PinData, connectPoint: CGPoint) {
        let stroke: PinStrokeView = PinStrokeView(begin: pinData.position, end: connectPoint, drawArea: frame.size)
        stroke.tag = pinData.number + max
        addSubview(stroke)
    }
    
    // ピン削除
    func deletePinco(pinNumber: Int) {
        deletePinMark(pinNumber)
        deleteConnection(pinNumber)
    }
    
    // ピンマーク削除
    private func deletePinMark(pinNumber: Int) {
        viewWithTag(pinNumber)?.removeFromSuperview()
    }
    
    // 連結線削除
    private func deleteConnection(pinNumber: Int) {
        viewWithTag(pinNumber + max)?.removeFromSuperview()
    }
    
    // ピン削除&再描画
    func deleteAndRedraw(pinData: PinData, connectPoint: CGPoint) {
        deletePinco(pinData.number)
        drawPinMark(pinData)
        drawConnection(pinData, connectPoint: connectPoint)
        setNeedsDisplay()
    }
}
