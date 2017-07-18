//
//  CGFloatExtensions.swift
//  DirectionRotate
//
//  Created by ShoIto on 2016/07/29.
//  Copyright © 2016年 ShoIto. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
    public func radiansToDegrees() -> CGFloat {
        return self * 180.0 / CGFloat(M_PI)
    }
    
    public func degreesToRadians() -> CGFloat {
        return self / 180.0 * CGFloat(M_PI)
    }
    
    public func radian(of side: CGFloat) -> CGFloat {
        return atan2(self, side)
    }
}