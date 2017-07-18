//
//  ViewController.swift
//  PinMarkMove
//
//  Created by ShoIto on 2016/06/08.
//  Copyright © 2016年 ShoIto. All rights reserved.
//

import UIKit

@objc enum PinMoveState: Int {
    case Movable
    case InMoving
}

class ViewController: UIViewController {
    
    let circleView = PinView(point: CGPointMake(100, 100), shape: .circle)
    let triangleView = PinView(point: CGPointMake(100, 150), shape: .triangle)
    let revTriangleView = PinView(point: CGPointMake(100, 200), shape: .revTriangle)
    let squareView = PinView(point: CGPointMake(150, 100), shape: .square)
    let starView = PinView(point: CGPointMake(200, 150), shape: .star)
    let hexagramView = PinView(point: CGPointMake(150, 150), shape: .hexagram)

    let directionKeyView = PinViewController.instance()
    
    var pinMoveState = PinMoveState.Movable
    var beforeMovingPosition = CGPointZero
    var selectedPin: PinView! {
        didSet {
            beforeMovingPosition = selectedPin.frame.origin
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        circleView.backgroundColor = .redColor()
        view.addSubview(circleView)
        
        triangleView.backgroundColor = .blueColor()
        view.addSubview(triangleView)
        
        squareView.backgroundColor = .greenColor()
        view.addSubview(squareView)

        revTriangleView.backgroundColor = .grayColor()
        view.addSubview(revTriangleView)
        
        squareView.backgroundColor = .greenColor()
        view.addSubview(squareView)

        starView.backgroundColor = .orangeColor()
        view.addSubview(starView)

        hexagramView.backgroundColor = .purpleColor()
        view.addSubview(hexagramView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        print("touch end")
        
        for touch: UITouch in touches {
            guard let touchView = touch.view else {
                return
            }
            if touchView.isKindOfClass(PinView.self) {
                // ピンを移動可能状態であれば、touchしたPinを選択する
                if pinMoveState == .Movable {
                    directionKeyView.delegate = self
                    selectedPin = touchView as! PinView
                    pinMoveState = .InMoving
                    
                    let screenFrame = UIScreen.mainScreen().bounds
                    directionKeyView.frame = CGRectMake(screenFrame.width - directionKeyView.frame.width,
                                                        0,
                                                        directionKeyView.frame.width,
                                                        directionKeyView.frame.height)
                    view.addSubview(directionKeyView)
                }
            }
        }
    }
}

extension ViewController: PinViewControllerDelegate {
    func pinViewController(pinViewController: PinViewController, transfer: Transfer) {
        selectedPin.move(transfer)
    }

    
    func pinViewController(pinViewController: PinViewController, decisionOnState state: PinDecisionState) {
        // Cancel時、座標戻す
        if state == .Cancel {
            selectedPin.frame.origin = beforeMovingPosition
        }
        directionKeyView.removeFromSuperview()
        beforeMovingPosition = CGPointZero
        pinMoveState = .Movable
    }
}

