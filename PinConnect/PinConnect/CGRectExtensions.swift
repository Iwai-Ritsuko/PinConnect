//
//  CGRectExtensions.swift
//  PinConnect
//
//  Created by KUROSAKI Ryota on 7/7/16.
//  Copyright © 2016 Ritsuko Iwai. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2.0,
                             y: center.y - size.height / 2.0)
        self = CGRect(origin: origin, size: size)
    }
    
    public func x(relative relative: CGFloat) -> CGFloat {
        return self.origin.x + self.width * relative
    }
    
    public func y(relative relative: CGFloat) -> CGFloat {
        return self.origin.y + self.height * relative
    }
    
    public func relativePoint(x rx: CGFloat, y ry: CGFloat) -> CGPoint {
        return CGPoint(x: x(relative: rx),
                       y: y(relative: ry))
    }
}

@objc enum PositionRelationVertical: Int {
    case bottom
    case middle
    case top
}

@objc enum PositionRelationHorizontal: Int {
    case right
    case middle
    case left
}

extension CGRect {
    func positionRelation(to otherRect: CGRect) -> (horizon: PositionRelationHorizontal, vertical: PositionRelationVertical) {

        let horizon: PositionRelationHorizontal
        if otherRect.maxX <= self.minX {
            horizon = .left
        } else if self.maxX <= otherRect.minX {
            horizon = .right
        } else {
            horizon = .middle
        }

        let vertical: PositionRelationVertical
        if otherRect.maxY <= self.minY {
            vertical = .top
        } else if self.maxY <= otherRect.minY {
            vertical = .bottom
        } else {
            vertical = .middle
        }
        
        return (horizon, vertical)
    }
}