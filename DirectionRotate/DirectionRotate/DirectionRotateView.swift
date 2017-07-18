//
//  DirectionRotateView.swift
//  DirectionRotate
//
//  Created by ShoIto on 2016/07/25.
//  Copyright © 2016年 ShoIto. All rights reserved.
//

import UIKit

protocol DirectionRotateViewDelegate {
    func directionRotateView(directionRotateView: DirectionRotateView, didDesideDirection:CGFloat)
}

enum TouchState {
    case Moved
    case Ended
}

class DirectionRotateView: UIView {
    
    private var cornerRadius: CGFloat {
        set {
            // 角丸
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    private var midPoint: CGPoint = .zero
    private var radius: CGFloat = 0.0
    private var viewAngle: CGFloat = 0.0
    var delegate: DirectionRotateViewDelegate?
    
    class func instance() -> DirectionRotateView {
        return UINib(nibName: "DirectionRotateView", bundle: nil).instantiateWithOwner(self, options: nil).first as! DirectionRotateView
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        midPoint = CGPointMake(frame.width / 2, frame.height / 2)
        radius = frame.width / 2
        cornerRadius = radius
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        guard touches.count == 1 else {
            return
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let currentPoint = touch.locationInView(self)
        let previousPoint = touch.previousLocationInView(self)
        
        // make sure the new point is within the area
        let distance = midPoint.distanceTo(point: currentPoint)
        
        if distance <= radius {
            // calculate rotation angle between two points
            var angle = midPoint.angleBetween(point1: previousPoint, point2: currentPoint)
            
            // fix value, if the 12 o'clock position is between prevPoint and nowPoint
            if angle > 180.0 {
                angle -= 360.0
            } else if angle < -180.0 {
                angle += 360.0
            }
            
            // sum up single steps
            viewAngle += angle
            if (viewAngle > 360.0) {
                viewAngle -= 360.0
            } else if (viewAngle < 0.0) {
                viewAngle += 360.0
            }
            // rotation view
            rotationView(angle: viewAngle, state: .Moved)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        rotationView(angle: viewAngle, state: .Ended)
    }
    
    private func fixedDirection(angle angle: CGFloat) -> CGFloat {
        let sixteenParts: CGFloat = 360.0 / 16.0
        // fixed angle
        let fixedAngle: CGFloat
        switch angle {
        case 0.0 ..< sixteenParts, sixteenParts * 15 ..< 360.0:
            fixedAngle = 0.0
        case sixteenParts ..< sixteenParts * 3:
            fixedAngle = sixteenParts * 2
        case sixteenParts * 3 ..< sixteenParts * 5:
            fixedAngle = sixteenParts * 4
        case sixteenParts * 5 ..< sixteenParts * 7:
            fixedAngle = sixteenParts * 6
        case sixteenParts * 7 ..< sixteenParts * 9:
            fixedAngle = sixteenParts * 8
        case sixteenParts * 9 ..< sixteenParts * 11:
            fixedAngle = sixteenParts * 10
        case sixteenParts * 11 ..< sixteenParts * 13:
            fixedAngle = sixteenParts * 12
        case sixteenParts * 13 ..< sixteenParts * 15:
            fixedAngle = sixteenParts * 14
        default:
            fixedAngle = 0.0
        }
        return fixedAngle
    }
    
    private func rotationView(angle angle: CGFloat, state: TouchState) {
        let directAngle = fixedDirection(angle: angle)
        // rotate image and update text field (directAngleの代わりにangleを渡すと360度回転タイプになる)
        transform = CGAffineTransformMakeRotation(directAngle.degreesToRadians());
        
        if state == .Ended {
            // pass direction (方向(enum)を渡す予定)
            delegate?.directionRotateView(self, didDesideDirection: directAngle)
        }
    }
}