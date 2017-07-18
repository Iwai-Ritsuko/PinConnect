//
//  ViewController.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/06/10.
//  Copyright (c) 2016年 Ritsuko Iwai. All rights reserved.
//

import UIKit

@objc enum PinReplaceType: Int {
    case none
    case connectPoint
    case number
}

@available(iOS 8.0, *)
class ViewController: UIViewController, InputViewControllerDelegate, PinNOClusterManagerDelegate, SwapViewDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var pinDrawView: PinDrawView!
    @IBOutlet weak var pinScrollView: UIScrollView! // ピン打ちクラスター
    @IBOutlet weak var pinListView: UIView!
    
    var pinManager: PinManager!
    var pinNoClusterManager: PinNOClusterManager!
    var endEditing = true
    var pinDetailViewController: InputViewController!
    var pinDetailPortraitPosition: PortraitDisplayPosition = .bottom    // 本当はサーバーから初期値を取得
    var pinDetailLandscapePosition: LandscapeDisplayPosition = .right   // 本当はサーバーから初期値を取得
    var currentPinNOCluster: PinNOClusterView?
    var replaceType: PinReplaceType = .none
    var swapView: SwapView? = nil
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinDrawView.userInteractionEnabled = true
        pinDrawView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.drawAreaTapped(_:))))
        // 本当はサーバーからの情報でピンの最大数を取得する
        pinDrawView.max = 16
        
        // 本当はサーバーからの情報でピンの最大数を取得してpinManagerを初期化する
        pinManager = PinManager.init(max: 16)
        
        // 本当はサーバーからの情報でクラスターIDの表とdocumentの情報を照らし合せてpinNOClusterManagerを初期化する
        pinNoClusterManager = PinNOClusterManager(baseView: pinScrollView)
        pinNoClusterManager.delegate = self
        
    }

    override func viewDidAppear(animated: Bool) {
        pinNoClusterManager.calculateConnectPoints(pinScrollView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UIGestureRecognizer
    func drawAreaTapped(sender: UIGestureRecognizer) {
        if replaceType != .none {
            return
        }
        let point: CGPoint = sender.locationOfTouch(0, inView: pinDrawView)
        if pinManager.hasFreePin() {
            let pData = PinData.init(location: point, pinNo: pinManager.nextFreePinNumber()!)
            showInputViewController(pData, state: .add)
        } else {
            // 追加できないアラート表示
            let alert = UIAlertController(title: "ピン子", message: "ピンをこれ以上追加できません", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Close", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - ViewManagement
    // ピン詳細画面生成
    private func showInputViewController(pData: PinData, state: PinState) {
        if pinDetailViewController == nil {
            let storyboard: UIStoryboard = UIStoryboard(name: "InputViewController", bundle: nil)
            pinDetailViewController = storyboard.instantiateInitialViewController() as! InputViewController
            pinDetailViewController.delegate = self
            pinDetailViewController.modalPresentationStyle = .Popover
        }
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        switch orientation {
        case .Portrait, .PortraitUpsideDown:
            if pinDetailPortraitPosition == .upSide {
                displayOnPinDrawView()
                pinDetailViewController.arrowImage = .bottom
            } else {
                displayOnPinListView()
                pinDetailViewController.arrowImage = .top
            }
        case .LandscapeRight, .LandscapeLeft:
            if pinDetailLandscapePosition == .left {
                displayOnPinDrawView()
                pinDetailViewController.arrowImage = .right
            } else {
                displayOnPinListView()
                pinDetailViewController.arrowImage = .left
            }
        default:
            break
        }
        
        pinDetailViewController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        pinDetailViewController.popoverPresentationController!.sourceView = view
        pinDetailViewController.popoverPresentationController!.delegate = self
        
        pinDetailViewController.pinData = pData
        pinDetailViewController.state = state
        
        endEditing = false
        presentViewController(pinDetailViewController, animated: true, completion: nil)
    }
    
    private func displayOnPinDrawView() {
        pinDetailViewController.preferredContentSize = CGSizeMake(pinScrollView.frame.width - 20, pinScrollView.frame.height - 20)
        pinDetailViewController.popoverPresentationController!.sourceRect = pinScrollView.frame
    }
    
    private func displayOnPinListView() {
        pinDetailViewController.preferredContentSize = CGSizeMake(pinListView.frame.width - 20, pinListView.frame.height - 20)
        pinDetailViewController.popoverPresentationController!.sourceRect = pinListView.frame
    }
    
    // MARK: - InputViewControllerDelegate
    func updatePin(pinData: PinData, state: PinState) {
        endEditing = true
        let cluster: PinNOClusterView
        switch state {
        case .add:
            cluster = pinNoClusterManager.pickNearestCluster(pinData.position)
            pinData.pinNOClusterID = cluster.clusterID
            pinManager.updatePin(pinData)
            pinDrawView.addPinco(pinData, connectPoint: cluster.connectPoint)
            pinNoClusterManager.updatePinNOCluster(cluster.clusterID, pinNumber: pinData.number)
        case .reedit:
            pinManager.updatePin(pinData)
            pinNoClusterManager.pinNOClusterViewDidEndEditing(pinData.number)
        case .cancel:
            pinNoClusterManager.pinNOClusterViewDidEndEditing(pinData.number)
        }
    }
    
    // ピン詳細画面の横画面表示位置を変更する
    func moveDetailPosition(pinData: PinData, state: PinState) {
        setPinDetailPositionWithDeviceOrientation()
        showInputViewController(pinData, state: state)
    }
    
    // 画面の向きに合わせて pinDetailPortraitPosition/pinDetailLandscapePosition をセットする
    private func setPinDetailPositionWithDeviceOrientation() {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        switch orientation {
        case .Portrait, .PortraitUpsideDown:
            if pinDetailPortraitPosition == .upSide {
                pinDetailPortraitPosition = .bottom
            } else {
                pinDetailPortraitPosition = .upSide
            }
        case .LandscapeRight, .LandscapeLeft:
            if pinDetailLandscapePosition == .left {
                pinDetailLandscapePosition = .right
            } else {
                pinDetailLandscapePosition = .left
            }
        default:
            break
        }
    }
    
    // MARK: - PinNOClusterManagerDelegate
    func pinNOClusterWillEdit(cluster: PinNOClusterView) {
        switch replaceType {
        case .number:
            self.showPinSwapAlert(cluster)
            cluster.blinkBorderWithColor(UIColor.greenColor())
        case .connectPoint:
            self.showPinSwapAlert(cluster)
            cluster.blinkBorderWithColor(UIColor.greenColor())
        case .none:
            showMenu(cluster)
        }
    }
    
    private func showPinSwapAlert(cluster: PinNOClusterView) {
        switch replaceType {
        case .number:
            let alert = UIAlertController(title: "ピンNo入れ替え", message: "ピン\(currentPinNOCluster!.pinNumber)とピン\(cluster.pinNumber)の番号を入れ替えますか", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "はい", style: .Default, handler: {
                (action: UIAlertAction!) -> Void in
                self.swapPinNo(cluster)
            })
            alert.addAction(yesAction)
            let noAction = UIAlertAction(title: "いいえ", style: .Cancel, handler: {
                (action: UIAlertAction) -> Void in
                self.cancelSwapPin(cluster)
            })
            alert.addAction(noAction)
            presentViewController(alert, animated: true, completion: nil)
        case .connectPoint:
            let alert = UIAlertController(title: "ピン配置入れ替え", message: "ピン\(currentPinNOCluster!.pinNumber)とピン\(cluster.pinNumber)の配置を入れ替えますか", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "はい", style: .Default, handler: {
                (action: UIAlertAction) -> Void in
                self.swapPinConnect(cluster)
            })
            alert.addAction(yesAction)
            let noAction = UIAlertAction(title: "いいえ", style: .Cancel, handler: {
                (action: UIAlertAction) -> Void in
                self.cancelSwapPin(cluster)
            })
            alert.addAction(noAction)
            presentViewController(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    // ピン番号を入れ替える
    private func swapPinNo(cluster: PinNOClusterView) {
        pinManager.replacePinNumber(currentPinNOCluster!.pinNumber, targetPinNo: cluster.pinNumber)
        pinNoClusterManager.replacePinNo(currentPinNOCluster!.pinNumber, targetNo: cluster.pinNumber)
        finishPinSwap(cluster)
    }
    
    // ピン配置を入れ替える
    private func swapPinConnect(cluster: PinNOClusterView) {
        pinManager.replacePinData(currentPinNOCluster!.pinNumber, targetPinNo: cluster.pinNumber)
        pinNoClusterManager.replacePinNo(currentPinNOCluster!.pinNumber, targetNo: cluster.pinNumber)
        redrawPinData(pinManager.pinDataArray)
        finishPinSwap(cluster)
    }
    
    private func cancelSwapPin(cluster: PinNOClusterView) {
        finishPinSwap(cluster)
    }
    
    private func finishPinSwap(cluster: PinNOClusterView) {
        currentPinNOCluster?.stopBlinkBorder()
        cluster.stopBlinkBorder()
        replaceType = .none
    }
    
    // MARK: - ピン編集メニュー
    // ピンの変更メニューを表示
    private func showMenu(cluster: PinNOClusterView) {
        currentPinNOCluster = cluster
        
        let alert = UIAlertController(title: "NO. \(cluster.pinNumber)", message: "", preferredStyle: .Alert)
        let action1 = UIAlertAction(title: "入力情報の編集", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            self.editPinTapped()
        })
        alert.addAction(action1)
        let action2 = UIAlertAction(title: "ピンの移動", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            self.movePinTapped()
        })
        alert.addAction(action2)
        
        if pinManager.usingPinCount() > 1 {
            let action3 = UIAlertAction(title: "ピン接続先入れ替え", style: .Default, handler: {
                (action: UIAlertAction!) -> Void in
                self.pinReplaceTapped(.connectPoint)
            })
            alert.addAction(action3)
            let action4 = UIAlertAction(title: "ピンNo入れ替え", style: .Default, handler: {
                (action: UIAlertAction!) -> Void in
                self.pinReplaceTapped(.number)
            })
            alert.addAction(action4)
        }
        
        let action5 = UIAlertAction(title: "ピンの削除", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            self.deletePinTapped()
        })
        alert.addAction(action5)
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.menuCancelTapped()
        })
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - ピン編集メニュータップ
    // ピンの編集が選ばれた
    func editPinTapped() {
        showInputViewController(pinManager[currentPinNOCluster!.pinNumber], state: .reedit)
    }
    
    // ピンの移動が選ばれた
    func movePinTapped() {
        pinNoClusterManager.pinNOClusterViewDidEndEditing(currentPinNOCluster!.pinNumber)
    }
    
    func pinReplaceTapped(type: PinReplaceType) {
        self.replaceType = type
        self.currentPinNOCluster!.blinkBorderWithColor(UIColor.redColor())
        self.displaySawpView()
        self.pinNoClusterManager.pinNOClusterViewDidEndEditing(currentPinNOCluster!.pinNumber)
    }
    
    // ピン削除がタップされた
    func deletePinTapped() {
        pinDrawView.deletePinco(currentPinNOCluster!.pinNumber)
        pinManager.deletePin(currentPinNOCluster!.pinNumber)
        pinNoClusterManager.pinNOClusterViewWillDelete(currentPinNOCluster!.clusterID)
    }
    
    // メニューのキャンセルがタップされた
    func menuCancelTapped() {
        pinNoClusterManager.pinNOClusterViewDidEndEditing(currentPinNOCluster!.pinNumber)
    }
    
    
    // ピンNo入れ替え・ピン配置入れ替え用のSwapView表示
    private func displaySawpView() {
        if swapView == nil {
            swapView = SwapView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
            swapView?.delegate = self
        }
        view.addSubview(swapView!)
        pinNoClusterManager.setPinNOClusterViewRect(swapView!)
        swapView?.pinNoClusterManager = pinNoClusterManager
    }
    
    // MARK: - SwapViewDelegate
    func pointedPinNoCluster(clusterID: Int, pinNo: Int) {
        swapView?.removeFromSuperview()
        swapView = nil
    }
    
    // ピンの再描画
    private func redrawPinData(pinData: [PinData]) {
        pinData.forEach {
            if $0.pinNOClusterID > 0 {
                let point = pinNoClusterManager.connectionPointAtPinNOClusterID($0.pinNOClusterID)
                pinDrawView.deleteAndRedraw($0, connectPoint: point)
                pinNoClusterManager.pinNOClusterNumberWillSet($0.pinNOClusterID, pinNumber: $0.number)
            }
        }
    }

    // MARK: - UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return endEditing
    }
}

