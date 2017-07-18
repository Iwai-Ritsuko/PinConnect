//
//  SnapViewController.swift
//  PinConnect
//
//  Created by Ritsuko Iwai on 2016/07/14.
//  Copyright © 2016年 Ritsuko Iwai. All rights reserved.
//

import UIKit
import AVFoundation

protocol SnapViewControllerDelegate {
    func snapped(snapData: NSData)
}

class SnapViewController: UIViewController, UIGestureRecognizerDelegate {
    var delegate: SnapViewControllerDelegate!
    var input: AVCaptureInput!
    var output: AVCaptureStillImageOutput!
    var session: AVCaptureSession!
    var camera: AVCaptureDevice!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet var preview: UIView!
    @IBOutlet var snapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedScreen(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedGesture(_:)))
        // デリゲートをセット
//        tapGesture.delegate = self
        // Viewにタップ、ピンチのジェスチャーを追加
//        self.view.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(pinchGesture)
        
        snapButton.layer.cornerRadius = 20.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startSesstion()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        for input in session.inputs {
            session.removeInput(input as! AVCaptureInput)
        }
        session = nil
        camera = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = preview.bounds
        previewLayer.connection.videoOrientation = videoOrientationFromCurrentDeviceOrientation()
    }
    
    func videoOrientationFromCurrentDeviceOrientation() -> AVCaptureVideoOrientation {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        switch orientation {
        case .Portrait:
            return .Portrait
        case .LandscapeLeft:
            return .LandscapeLeft
        case .LandscapeRight:
            return .LandscapeRight
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        default:
            return .Portrait;
        }
    }
    
    func startSesstion() {
        session = AVCaptureSession()
        for captureDevice in AVCaptureDevice.devices() {
            if captureDevice.position == AVCaptureDevicePosition.Back {
                camera = captureDevice as? AVCaptureDevice
                break
            }
        }
        
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch {
            input = nil
        }
        session.addInput(input)
        
        output = AVCaptureStillImageOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.startRunning()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = preview.frame
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.layer.addSublayer(previewLayer)
    }
    
    // Gesture
    let focusView = UIView()
    func tappedScreen(gestureRecognizer: UITapGestureRecognizer) {
        let tapCGPoint = gestureRecognizer.locationOfTouch(0, inView: gestureRecognizer.view)
        focusView.frame.size = CGSize(width: 120, height: 120)
        focusView.center = tapCGPoint
        focusView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        focusView.layer.borderColor = UIColor.whiteColor().CGColor
        focusView.layer.borderWidth = 2
        focusView.alpha = 1
        preview.addSubview(focusView)
        
        UIView.animateWithDuration(0.5, animations: {
            self.focusView.frame.size = CGSize(width: 80, height: 80)
            self.focusView.center = tapCGPoint
            }, completion: { Void in
                UIView.animateWithDuration(0.5, animations: {
                    self.focusView.alpha = 0
                })
        })
        
        self.focusWithMode(AVCaptureFocusMode.AutoFocus, exposeWithMode: AVCaptureExposureMode.AutoExpose, atDevicePoint: tapCGPoint, motiorSubjectAreaChange: true)
    }
    
    private func focusWithMode(focusMode : AVCaptureFocusMode, exposeWithMode expusureMode :AVCaptureExposureMode, atDevicePoint point:CGPoint, motiorSubjectAreaChange monitorSubjectAreaChange:Bool) {
        
        dispatch_async(dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL), {
            let device : AVCaptureDevice = self.camera
            
            do {
                try device.lockForConfiguration()
                if(device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode)){
                    device.focusPointOfInterest = point
                    device.focusMode = focusMode
                }
                if(device.exposurePointOfInterestSupported && device.isExposureModeSupported(expusureMode)){
                    device.exposurePointOfInterest = point
                    device.exposureMode = expusureMode
                }
                
                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
                
            } catch let error as NSError {
                print(error.debugDescription)
            }
            
        })
    }
    
    var oldZoomScale: CGFloat = 1.0
    func pinchedGesture(gestureRecgnizer: UIPinchGestureRecognizer) {
        do {
            try camera.lockForConfiguration()
            // ズームの最大値
            let maxZoomScale: CGFloat = 6.0
            // ズームの最小値
            let minZoomScale: CGFloat = 1.0
            // 現在のカメラのズーム度
            var currentZoomScale: CGFloat = camera.videoZoomFactor
            // ピンチの度合い
            let pinchZoomScale: CGFloat = gestureRecgnizer.scale
            
            // ピンチアウトの時、前回のズームに今回のズーム-1を指定
            // 例: 前回3.0, 今回1.2のとき、currentZoomScale=3.2
            if pinchZoomScale > 1.0 {
                currentZoomScale = oldZoomScale+pinchZoomScale-1
            } else {
                currentZoomScale = oldZoomScale-(1-pinchZoomScale)*oldZoomScale
            }
            
            // 最小値より小さく、最大値より大きくならないようにする
            if currentZoomScale < minZoomScale {
                currentZoomScale = minZoomScale
            }
            else if currentZoomScale > maxZoomScale {
                currentZoomScale = maxZoomScale
            }
            
            // 画面から指が離れたとき、stateがEndedになる。
            if gestureRecgnizer.state == .Ended {
                oldZoomScale = currentZoomScale
            }
            
            camera.videoZoomFactor = currentZoomScale
            camera.unlockForConfiguration()
        } catch {
            // handle error
            return
        }
    }
    
    // MARK - IBAction
    @IBAction func snapButtonDidTapped(sender: AnyObject) {
        let videoConnection = output.connectionWithMediaType(AVMediaTypeVideo)
        if videoConnection.supportsVideoOrientation {
            videoConnection.videoOrientation = videoOrientationFromCurrentDeviceOrientation()
        }
        output.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            self.delegate.snapped(imageData)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func cancelButtonDidTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
