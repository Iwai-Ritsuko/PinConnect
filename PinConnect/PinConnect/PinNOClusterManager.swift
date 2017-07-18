//
//  PinNOClusterManager.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/13.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

// ピンNO配置クラスターの管理クラス

import UIKit

@objc protocol PinNOClusterManagerDelegate {
    func pinNOClusterWillEdit(cluster: PinNOClusterView)
}

class PinNOClusterManager: NSObject, PinNoClusterViewDelegate {
    var clusterArray: [PinNOClusterView] = []
    var delegate: PinNOClusterManagerDelegate!
    
    init(baseView: UIView) {
        clusterArray = PinNOClusterManager.createClusterArray(baseView)
        
        // PinNOClusterViewの枠線を引く. 実際は不要
        clusterArray.forEach {
            $0.backgroundColor = UIColor.clearColor()
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor.blueColor().CGColor
        }
    }
    
    // Viewに貼り付けられているPinNOClusterを探す
    // 実際は不要
    static func findPinNOClusters(baseView: UIView) -> [UIView]? {
        return baseView.subviews.filter { $0 is PinNOClusterView }
    }
    
    // Viewに貼り付けられているPinNoClusterのArrayを作りclusterIDにtagをセットする
    // 実際は不要
    static func createClusterArray(baseView: UIView) -> [PinNOClusterView] {
        guard let clusters = PinNOClusterManager.findPinNOClusters(baseView) as? [PinNOClusterView] else {
            return []
        }
        clusters.forEach {
            $0.clusterID = $0.tag
        }
        return clusters
    }
    
    // 連結線の接続ポイントを算出する
    func calculateConnectPoints(baseView: UIView) {
        if let drawView = findPinDrawView(from: baseView) {
            clusterArray.forEach { $0.calculateConnectPoint(to: drawView) }
        }
    }
    
    // PinNOClusterViewの座標をセットする
    func setPinNOClusterViewRect(baseView: UIView) {
        clusterArray.forEach { $0.adjustLocation(baseView) }
    }
    
    // PinNOClusterViewの輪郭を点滅させる
    func blinkBorderWithColor(clusterID: Int) {
        if let index = clusterArray.indexOf({ $0.clusterID == clusterID }) {
            clusterArray[index].blinkBorderWithColor(UIColor.redColor())
        }
    }
    
    func stopBlinkBorder(clusterID: Int) {
        if let index = clusterArray.indexOf({ $0.clusterID == clusterID }) {
            clusterArray[index].stopBlinkBorder()
        }
    }

    // ピン打ちクラスターを返す
    private func findPinDrawView(from view: UIView) -> PinDrawView? {
        return view.subviews
            .indexOf { $0 is PinDrawView }
            .flatMap { view.subviews[$0] as? PinDrawView }
    }
    
    // ピン打ちクラスターのframeを返す
    private func findPinDrawViewRect(baseView: UIView) -> CGRect? {
        return findPinDrawView(from: baseView).flatMap { $0.frame }
    }

    // タップ座標から一番近く空いているクラスターを返す
    func pickNearestCluster(location: CGPoint) -> PinNOClusterView {
        return clusterArray
            .filter { $0.pinNumber == 0 }
            .minElement { $0.distanceTo(location) < $1.distanceTo(location) }!
    }
    
    subscript(clusterID: Int) -> PinNOClusterView? {
        get {
            return clusterArray
                .indexOf { $0.clusterID == clusterID }
                .flatMap { clusterArray[$0] }
        }
        set {
            if let newValue = newValue, index = clusterArray.indexOf({$0.clusterID == clusterID}) {
                clusterArray[index] = newValue
            }
        }
    }

    // ピンNO配置クラスターの情報更新
    func updatePinNOCluster(clusterID: Int, pinNumber: Int) {
        if let index = clusterArray.indexOf({ $0.clusterID == clusterID }) {
            clusterArray[index].updatePinNumber(pinNumber)
            clusterArray[index].delegate = self
        }
    }
    
    // ピンの編集終了通知
    func pinNOClusterViewDidEndEditing(pinNumber: Int) {
        if let index = clusterArray.indexOf({ $0.pinNumber == pinNumber }) {
            clusterArray[index].touched = false
        }
    }
    
    // ピンNO配置クラスターのIDから接続ポイントを返す
    func connectionPointAtPinNOClusterID(clusterID: Int) -> CGPoint {
        guard let index = clusterArray.indexOf({ $0.clusterID == clusterID }) else {
            return CGPointZero
        }
        return clusterArray[index].connectPoint
    }
    
    // ピン削除
    func pinNOClusterViewWillDelete(clusterID: Int) {
        if let index = clusterArray.indexOf({ $0.clusterID == clusterID }) {
            clusterArray[index].deletePinNO()
        }
    }
    
    // ピンNoセット
    func pinNOClusterNumberWillSet(clusterID: Int, pinNumber: Int) {
        if let index = clusterArray.indexOf({ $0.clusterID == clusterID }) {
            clusterArray[index].updatePinNumber(pinNumber)
        }
    }
    
    // ピンNo入れ替え
    func replacePinNo(sourceNo: Int, targetNo: Int) {
        let sourceIndex = clusterArray.indexOf({ $0.pinNumber == sourceNo })
        let source = clusterArray[sourceIndex!]
        
        let targetIndex = clusterArray.indexOf({ $0.pinNumber == targetNo })
        let target = clusterArray[targetIndex!]
        
        pinNOClusterNumberWillSet(source.clusterID, pinNumber: targetNo)
        pinNOClusterNumberWillSet(target.clusterID, pinNumber: sourceNo)
    }
    
    // ピンNoのclusterIDと一致するlocationを返す
    func pinNOClusterLocation(fromID: Int) -> CGRect {
        if let index = clusterArray.indexOf({ $0.clusterID == fromID }) {
            return clusterArray[index].location
        }
        return CGRectZero
    }
    
    // MARK: - pinNOClusterViewDelegate
    func pinNOClusterWillEdit(clusterID: Int) {
        if let index = clusterArray.indexOf({ $0.clusterID == clusterID }) {
            delegate.pinNOClusterWillEdit(clusterArray[index])
        }
    }
}
