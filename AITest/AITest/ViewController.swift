//
//  ViewController.swift
//  AITest
//
//  Created by 邓升发 on 2020/4/29.
//  Copyright © 2020 com.YouMa. All rights reserved.
//

import UIKit
import CoreMedia
import Vision
import os.signpost

class ViewController: UIViewController {
    
    @IBOutlet var videoPreview: UIView!
    
    @IBOutlet var captureBtn: UIButton!
    //匹配率展示label
    var matchingRatioL : UILabel!
    var matchCountL : UILabel!
    
    
    var jointView: DrawingJointView!
    
    var capturedJointView: DrawingJointView!
    /// 已捕获的点
    var capturedPoint: [CapturedPoint?]?
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    
    // MARK: - ML Properties
    // Core ML model
    typealias EstimationModel = model_cpm
    
    // Preprocess and Inference
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    // Postprocess
    var postProcessor: HeatmapPostProcessor = HeatmapPostProcessor()
    var mvfilters: [MovingAverageFilter] = []
    
    var hasAdd : Bool = false
    var sumMatchCount : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white;
        
        setupUI()
        // setup the drawing views
        setUpCapturedJointView()

        // setup the model
        setUpModel()
        
        // setup camera
        setUpCamera()
        
    }
    func setupUI() {
        videoPreview = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        videoPreview.backgroundColor = UIColor.clear
        view.addSubview(videoPreview)
        
        jointView = DrawingJointView(frame: videoPreview.bounds)
        jointView.backgroundColor = UIColor.clear;
        jointView.isUserInteractionEnabled = false
        view.addSubview(jointView);
//        videoPreview.bringSubviewToFront(jointView)
        
        let whiteBgView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height-100, width: UIScreen.main.bounds.size.width, height: 100))
        whiteBgView.backgroundColor = UIColor.white;
        view.addSubview(whiteBgView);
        
        
        
        capturedJointView = DrawingJointView(frame: CGRect(x: UIScreen.main.bounds.size.width/2.0-100, y: 10, width: 80, height: 80))
        capturedJointView.layer.borderWidth = 2
        capturedJointView.layer.borderColor = UIColor.gray.cgColor
        capturedJointView.backgroundColor = UIColor.clear
        whiteBgView.addSubview(capturedJointView)
        
        
        captureBtn = UIButton.init()
        whiteBgView.addSubview(captureBtn)
        captureBtn.addTarget(self, action: #selector(captureClick), for: .touchUpInside)
        captureBtn.setTitle("捕获骨架", for: .normal)
        captureBtn.setTitleColor(UIColor.black, for: .normal)
        captureBtn.titleLabel?.textAlignment = .center
        captureBtn.backgroundColor = UIColor.lightGray
        captureBtn.layer.cornerRadius = 10
        captureBtn.layer.masksToBounds = true
        captureBtn.frame = CGRect(x: UIScreen.main.bounds.size.width/2.0+50, y: 5, width: 100, height: 30)
        
        matchingRatioL = UILabel.init(frame: CGRect(x: UIScreen.main.bounds.size.width/2.0+50, y: 40, width: 120, height: 20))
        matchingRatioL.text = "";
        matchingRatioL.textColor = UIColor.red
        matchingRatioL.font = UIFont.systemFont(ofSize: 17)
        matchingRatioL.textAlignment = .center
        whiteBgView.addSubview(matchingRatioL)
        
        matchCountL = UILabel.init(frame: CGRect(x: UIScreen.main.bounds.size.width/2.0+50, y: 70, width: 110, height: 20))
        matchCountL.text = "";
        matchCountL.textColor = UIColor.red
        matchCountL.font = UIFont.systemFont(ofSize: 17)
        matchCountL.textAlignment = .center
        whiteBgView.addSubview(matchCountL)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - Setup Captured Joint View
    func setUpCapturedJointView() {
//        postProcessor.onlyBust = false
        
        
        if let data = UserDefaults.standard.data(forKey: "points-1"),
            let capturedPoints = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CapturedPoint?] {
            
            //模拟服务端至少返回8个以上的point,x,y对应点在视图在xy方向的比例
//            let capPoint1 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.2586805555555555, y: 0.19965277777777776), maxConfidence: 1.0))
//            let capPoint2 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.3142361111111111, y: 0.3107638888888889), maxConfidence: 1.0))
//            let capPoint3 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.203125, y: 0.7552083333333334), maxConfidence: 1.0))
//            let capPoint4 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.9114583333333334, y: 0.005208333333333333), maxConfidence: 1.0))
//            let capPoint5 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.7447916666666667, y: 0.8802083333333334), maxConfidence: 1.0))
//            let capPoint6 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.24479166666666663, y: 0.8385416666666666), maxConfidence: 1.0))
//            let capPoint7 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.3542361111111111, y: 0.3907638888888889), maxConfidence: 1.0))
//            let capPoint8 = CapturedPoint(predictedPoint: PredictedPoint(maxPoint: CGPoint(x: 0.3942361111111111, y: 0.3507638888888889), maxConfidence: 1.0))
//            var capPointArr = [CapturedPoint]()
//            capPointArr.append(capPoint1)
//            capPointArr.append(capPoint2)
//            capPointArr.append(capPoint3)
//            capPointArr.append(capPoint4)
//            capPointArr.append(capPoint5)
//            capPointArr.append(capPoint6)
//            capPointArr.append(capPoint7)
//            capPointArr.append(capPoint8)
//            capturedPoint = capPointArr
//            if let point = capturedPoint?[0] {
//                print(point.point)
//            }
            capturedPoint = capturedPoints
            capturedJointView.bodyPoints = capturedPoints.map { capturedPointOne in
                if let singleCapturedPoint = capturedPointOne {
                    return PredictedPoint(capturedPoint: singleCapturedPoint)
                }
                else { return nil }
            }
        }
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: EstimationModel().model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError("cannot load the ml model")
        }
    }
    
    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .hd1280x720, cameraPosition: .back) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    @objc func captureClick() {
        
        let predictedPoints = jointView.bodyPoints
        capturedJointView.bodyPoints = predictedPoints
        let capturedPoints: [CapturedPoint?] = predictedPoints.map { predictedPoint in
            guard let predictedPoint = predictedPoint else { return nil }
            return CapturedPoint(predictedPoint: predictedPoint)
        }
        capturedPoint = capturedPoints
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: capturedPoints)
        UserDefaults.standard.set(encodedData, forKey: "points-1")
    }
    

}
// MARK: - VideoCaptureDelegate
extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
         if let pixelBuffer = pixelBuffer {
                   // predict!
                   self.predictUsingVision(pixelBuffer: pixelBuffer)
               }
    }
}
extension ViewController {
    // MARK: - Inferencing
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
        
    }
    
    // MARK: - Postprocessing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
        let heatmaps = observations.first?.featureValue.multiArrayValue {
        
        /* =================================================================== */
        /* ========================= post-processing ========================= */
        
        /* ------------------ convert heatmap to point array ----------------- */
        var predictedPoints = postProcessor.convertToPredictedPoints(from: heatmaps, isFlipped: true)
        
        /* --------------------- moving average filter ----------------------- */
        if predictedPoints.count != mvfilters.count {
            mvfilters = predictedPoints.map { _ in MovingAverageFilter(limit: 3) }
        }
        for (predictedPoint, filter) in zip(predictedPoints, mvfilters) {
            filter.add(element: predictedPoint)
        }
        predictedPoints = mvfilters.map { $0.averagedValue() }
        /* =================================================================== */
        
        
        let matchingRatio : CGFloat = (capturedPoint?.matchVector(with: predictedPoints)) ?? 0
        if matchingRatio > 0.90 && hasAdd == false {
            sumMatchCount += 1;
            hasAdd = true;
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hasAdd = false;
        }
        /// 显示结果到页面上
        DispatchQueue.main.sync {
            // draw line
            self.jointView.bodyPoints = predictedPoints
            matchingRatioL.text = String.init(format: "匹配率%.2f%%", matchingRatio*100)
            matchCountL.text = String.init(format: "已完成:%d个", sumMatchCount)
        }
        /* =================================================================== */
        }else{
        }
    }
}
