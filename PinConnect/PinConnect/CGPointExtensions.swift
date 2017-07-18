//
//  CGPointExtensions.swift
//  PinConnect
//
//  Created by KUROSAKI Ryota on 7/7/16.
//  Copyright © 2016 Ritsuko Iwai. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    public func distanceTo(point point: CGPoint = CGPoint.zero) -> CGFloat {
        let xx = pow(point.x - self.x, 2)
        let yy = pow(point.y - self.y, 2)
        return sqrt(xx + yy)
    }
    
    public func distanceTo(x x: CGFloat, y: CGFloat) -> CGFloat {
        return distanceTo(point: CGPoint(x: x, y: y))
    }
}