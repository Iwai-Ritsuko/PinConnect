//
//  PinViewController.swift
//  PinMarkMove
//
//  Created by ShoIto on 2016/06/08.
//  Copyright © 2016年 ShoIto. All rights reserved.
//

import UIKit

@objc enum ArrowDirection: Int {
    case Unknown
    case Up
    case Right
    case Down
    case Left
}

@objc enum PinDecisionState: Int {
    case Decide
    case Cancel
}

class Transfer: NSObject {
    var direction: ArrowDirection
    var distance: CGFloat
    
    init(direction: ArrowDirection, distance: CGFloat) {
        self.direction = direction
        self.distance = distance
    }
    
    func apply(to rect: CGRect) -> CGRect {
        var newRect = rect
        switch direction {
        case .Up:
            newRect.origin.y -= distance
        case .Right:
            newRect.origin.x += distance
        case .Down:
            newRect.origin.y += distance
        case .Left:
            newRect.origin.x -= distance
        case .Unknown:
            break
        }
        return newRect
    }
}

@objc protocol PinViewControllerDelegate {
    func pinViewController(pinViewController: PinViewController, transfer: Transfer)
    func pinViewController(pinViewController: PinViewController, decisionOnState state: PinDecisionState)
}

class PinViewController: UIView {
    
    weak var delegate: PinViewControllerDelegate?
    private var timer = NSTimer()
    private var countTimer: NSTimeInterval = 0.0
    private let timeInterval: NSTimeInterval = 0.2
    private let minimumMoveValue: CGFloat = 1.0
    private let maximumMoveValue: CGFloat = 3.0
    private var moveValue: CGFloat {
        // ボタンの押している時間で移動量が変化
        if countTimer > 2.0 {
            return maximumMoveValue
        } else {
            return minimumMoveValue
        }
    }
    private let tagKey = "viewTagKey"
    
    class func instance() -> PinViewController {
        return UINib(nibName: "PinViewController", bundle: nil).instantiateWithOwner(self, options: nil).first as! PinViewController
    }
    
    // MARK: - IBAction
    @IBAction func tappedOKButton(sender: AnyObject) {
        delegate?.pinViewController(self, decisionOnState: .Decide)
    }
    
    @IBAction func tappedCancelButton(sender: AnyObject) {
        delegate?.pinViewController(self, decisionOnState: .Cancel)
    }
    
    @IBAction func touchDownArrowButton(sender: AnyObject) {
        guard let direction = ArrowDirection(rawValue: sender.tag) else {
            return
        }
        // Transferインスタンスを生成してdelegate先へ渡す
        passTransfer(direction: direction, distance: moveValue)
    }
    
    @IBAction func holdDownArrowButton(sender: UILongPressGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        // LongPressGestureの状態に応じて処理
        switch sender.state {
        case .Possible, .Failed, .Cancelled:
            break
        case .Began:
            // userInfoを使う場合、下記でセットした値でリピートされるため長押し時間で移動量を可変にするのは無理
            if !timer.valid {
                timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
                                                               target: self,
                                                               selector: #selector(continuousMove),
                                                               userInfo: [tagKey : view.tag],
                                                               repeats: true)
            }
        case .Changed, .Ended:
            timer.invalidate()
            // countTimerのリセットと単押し用に移動量の初期化
            countTimer = 0
        }
    }
    
    //MARK: - Private Method
    @objc private func continuousMove() {
        guard let tag = timer.userInfo?[tagKey] as? Int,
            direction = ArrowDirection(rawValue: tag) else {
                return
        }
        // moveValueの値変動させるため、ボタンの押している時間を計測
        countTimer += timeInterval
        
        // Transferインスタンスを生成してdelegate先へ渡す
        passTransfer(direction: direction, distance: moveValue)
    }
    
    // transferインスタンスを生成してdelegate先に渡す
    private func passTransfer(direction direction: ArrowDirection, distance: CGFloat) {
        let transfer = Transfer(direction: direction, distance: distance)
        delegate?.pinViewController(self, transfer: transfer)
    }
}