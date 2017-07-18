//
//  PinManager.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/13.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

// ピンデータ管理クラス

import UIKit

class PinManager: NSObject {
    var pinDataArray: [PinData] = []
    
    init(max: Int) {
        pinDataArray = (1...max).map { index in return PinData(location: CGPointZero, pinNo: index) }
    }
    
    // 空いている最小のピンNOを返す
    func nextFreePin() -> PinData? {
        for pinData in pinDataArray {
            if pinData.isFree {
                return pinData
            }
        }
        return nil
    }
    
    func nextFreePinNumber() -> Int? {
        return nextFreePin().flatMap { $0.number }
    }

    func hasFreePin() -> Bool {
        return nextFreePin() != nil
    }
    
    // 現在追加されているピンの個数を返す
    func usingPinCount() -> Int {
        return pinDataArray.filter { !$0.isFree }.count
    }

    // 現在空いているピンの個数を返す
    func freePinCount() -> Int {
        return pinDataArray.filter { $0.isFree }.count
    }
   
    // ピンデータ更新
    func updatePin(pinData: PinData) {
        self[pinData.number] = pinData
    }
    
    // ピンデータ削除
    func deletePin(pinNumber: Int) {
        if let index = pinDataArray.indexOf({ $0.number == pinNumber }) {
            pinDataArray[index].reset()
        }
    }
    
    subscript(pinNumber: Int) -> PinData {
        get {
            let index = pinDataArray.indexOf { $0.number == pinNumber }!
            return pinDataArray[index]
        }
        set {
            let index = pinDataArray.indexOf({ $0.number == pinNumber })!
            pinDataArray[index] = newValue
        }
    }
    
    // ピンNOに対応するピンデータを返す
    func pinDataAtPinNumber(pinNumber: Int) -> PinData? {
        return self[pinNumber]
    }
    
    // ピンNO入れ替え
    func replacePinNumber(sourcePinNo: Int, targetPinNo: Int) {
        let sourceData = self[sourcePinNo]
        let targetData = self[targetPinNo]
        sourceData.number = sourcePinNo
        targetData.number = targetPinNo
    }
    
    // ピンアイテム入れ替え
    func replacePinData(sourcePinNo: Int, targetPinNo: Int) {
        let sourceData = self[sourcePinNo]
        let targetData = self[targetPinNo]
        let saveClusterID = sourceData.pinNOClusterID
        sourceData.pinNOClusterID = targetData.pinNOClusterID
        targetData.pinNOClusterID = saveClusterID
    }
    
}
