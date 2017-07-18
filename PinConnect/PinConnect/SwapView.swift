//
//  SwapView.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/07/21.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

import UIKit

@objc protocol SwapViewDelegate {
    func pointedPinNoCluster(clusterID: Int, pinNo: Int)
}

class SwapView: UIView {
    var pinNoClusterManager: PinNOClusterManager? = nil
    var delegate: SwapViewDelegate!
    var tapRect = CGRectZero
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        pinNoClusterManager?.clusterArray.forEach {
            if CGRectContainsPoint($0.location, point) {
                delegate.pointedPinNoCluster($0.clusterID, pinNo: $0.pinNumber)
            }
        }
        return super.hitTest(point, withEvent: event)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
