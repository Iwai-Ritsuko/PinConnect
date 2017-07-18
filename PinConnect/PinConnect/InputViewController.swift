//
//  InputViewController.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/13.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

import UIKit

@objc protocol InputViewControllerDelegate {
    func updatePin(pinData: PinData, state: PinState)
    func moveDetailPosition(pinData: PinData, state: PinState)
}

@objc enum PinState: Int {
    case add
    case reedit
    case cancel
}

@objc enum PortraitDisplayPosition: Int {
    case upSide
    case bottom
}

@objc enum LandscapeDisplayPosition: Int {
    case right
    case left
}

@objc enum ArrowImage: Int {
    case top
    case bottom
    case right
    case left
}

class InputViewController : UIViewController, SnapViewControllerDelegate {
    @IBOutlet weak var PinNoLabel: UILabel!
    var pinData: PinData!
    var delegate: InputViewControllerDelegate!
    var state: PinState = .add
    var snapViewController: SnapViewController? = nil
    var arrowImage: ArrowImage = .left
    @IBOutlet var snapImageView: UIImageView!
    @IBOutlet var arrowButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        PinNoLabel.text = "No. \(String(pinData.number))"
        
        let name: String
        switch arrowImage {
        case .top:
            name =  "033"
        case .bottom:
            name =  "029"
        case .right:
            name =  "027"
        case .left:
            name =  "031"
        }
        arrowButton.setImage(UIImage(named: name), forState: UIControlState.Normal)
        
        detailContents()
        photoArea()
    }
    
    // 定義された入力クラスターをセットする
    private func detailContents() {
        
    }
    
    // 写真エリアのデータセット
    private func photoArea() {
        // TODO: 撮影方向のセット
        
        deleteButton.enabled = false
        snapImageView.image = nil
        if pinData.photo != nil {
            if let image = UIImage(data: (pinData.photo?.binary)!) {
                snapImageView.image = image
                deleteButton.enabled = true
            }
        }
    }
    
    @IBAction func cancelButtonDidTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
            self.delegate.updatePin(self.pinData, state: .cancel)
        })
    }
    
    @IBAction func okButtonDidTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
            self.delegate.updatePin(self.pinData, state: self.state)
        })
    }
    
    @IBAction func cameraButtonDidTapped(sender: AnyObject) {
        if snapImageView.image == nil {
            showSnapViewController()
        } else {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "ピン詳細", message: "再撮影しますか？", preferredStyle: .Alert)
                let noAction = UIAlertAction(title: "いいえ", style: .Cancel, handler: nil)
                alert.addAction(noAction)
                let yesAction = UIAlertAction(title: "はい", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                    self.pinData.photo = nil
                    self.showSnapViewController()
                })
                alert.addAction(yesAction)
                presentViewController(alert, animated: true, completion: nil)
            } else {
                // iOS7は対応なし
            }
        }
    }
    
    func showSnapViewController() {
        if snapViewController == nil {
            let storyboard = UIStoryboard(name: "SnapViewController", bundle: nil)
            snapViewController = storyboard.instantiateInitialViewController() as? SnapViewController
            snapViewController!.delegate = self
        }
        presentViewController(snapViewController!, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonDidTapped(sender: AnyObject) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "ピン詳細", message: "撮影データを削除しますか？", preferredStyle: .Alert)
            let noAction = UIAlertAction(title: "いいえ", style: .Cancel, handler: nil)
            alert.addAction(noAction)
            let yesAction = UIAlertAction(title: "はい", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                self.pinData.photo = nil
                self.snapImageView.image = nil
            })
            alert.addAction(yesAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            // iOS7は対応なし
        }
    }
    
    @IBAction func arrowButtonDidTapped(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: {
            self.delegate.moveDetailPosition(self.pinData, state: self.state)
        })
    }
    
    // MARK - SnapViewControllerDelegate
    func snapped(snapData: NSData) {
        let image: UIImage = UIImage(data: snapData)!
        snapImageView.image = image
        pinData.photo = PinData.Photo(binary: snapData)
        deleteButton.enabled = true
        
    }
}
