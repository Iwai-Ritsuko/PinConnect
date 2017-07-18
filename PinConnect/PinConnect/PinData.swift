//
//  PinData.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/13.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

// ピンデータクラス

import UIKit

@objc enum SnapDirection: Int {
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest
    case none
}

class PinData: NSObject, NSCopying {
    
    @objc(PinPhotoData)
    class Photo: NSObject, NSCopying {
        var binary: NSData
        var direction: SnapDirection
        
        init(binary: NSData, direction: SnapDirection = .none) {
            self.binary = binary
            self.direction = direction
        }
        
        func copyWithZone(zone: NSZone) -> AnyObject {
            return Photo(binary: binary, direction: direction)
        }
    }
    
    var position: CGPoint
    var number: Int
    var pinNOClusterID: Int
    var pinListHeaderID: Int
    var photo: Photo?
    var isFree: Bool {
        return position == CGPoint.zero
    }

    init(location: CGPoint, pinNo: Int) {
        position = location
        number = pinNo
        pinNOClusterID = 0
        pinListHeaderID = 0
    }
    
    func reset() {
        position = CGPointZero
        pinNOClusterID = 0
        pinListHeaderID = 0
        photo = nil
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = PinData(location: position, pinNo: number)
        copy.pinNOClusterID = pinNOClusterID
        copy.pinListHeaderID = pinListHeaderID
        copy.photo = photo?.copy() as? Photo
        return copy
    }
}
