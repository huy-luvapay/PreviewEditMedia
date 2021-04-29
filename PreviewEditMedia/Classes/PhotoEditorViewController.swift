//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

public var switchCam = Bool()


internal extension UIImage {
    
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Kudos to Trevor Harmon and his UIImage+Resize category from
    // which this code is heavily inspired.
    func resetOrientation() -> UIImage {
        // Image has no orientation, so keep the same
        if imageOrientation == .up {
            return self
        }
        
        // Process the transform corresponding to the current orientation
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:           // EXIF = 3, 4
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left, .leftMirrored:           // EXIF = 6, 5
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            
        case .right, .rightMirrored:          // EXIF = 8, 7
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat((Double.pi / 2)))
        default:
            ()
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:     // EXIF = 2, 4
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:   //EXIF = 5, 7
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            ()
        }
        
        // Draw a new image with the calculated transform
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage!.bitsPerComponent,
                                bytesPerRow: 0,
                                space: cgImage!.colorSpace!,
                                bitmapInfo: cgImage!.bitmapInfo.rawValue)
        context?.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        if let newImageRef =  context?.makeImage() {
            let newImage = UIImage(cgImage: newImageRef)
            return newImage
        }
        
        // In case things go wrong, still return self.
        return self
    }
    
    
    fileprivate func cappedSize(for size: CGSize, cappedAt: CGFloat) -> CGSize {
        var cappedWidth: CGFloat = 0
        var cappedHeight: CGFloat = 0
        if size.width > size.height {
            // Landscape
            let heightRatio = size.height / size.width
            cappedWidth = min(size.width, cappedAt)
            cappedHeight = cappedWidth * heightRatio
        } else if size.height > size.width {
            // Portrait
            let widthRatio = size.width / size.height
            cappedHeight = min(size.height, cappedAt)
            cappedWidth = cappedHeight * widthRatio
        } else {
            // Squared
            cappedWidth = min(size.width, cappedAt)
            cappedHeight = min(size.height, cappedAt)
        }
        return CGSize(width: cappedWidth, height: cappedHeight)
    }
    
    func toCIImage() -> CIImage? {
        return self.ciImage ?? CIImage(cgImage: self.cgImage!)
    }
}

internal extension CIImage {
    func toUIImage() -> UIImage {
        /*
            If need to reduce the process time, than use next code.
            But ot produce a bug with wrong filling in the simulator.
            return UIImage(ciImage: self)
         */
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(self, from: self.extent)!
        let image: UIImage = UIImage(cgImage: cgImage)
        return image
    }
    
    func toCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return cgImage
        }
        return nil
    }
}

open class PreviewEditMedia {
    open class func podBundleImage(named: String) -> UIImage? {
        let podBundle = Bundle(for: PhotoEditorViewController.self)
        if let url = podBundle.url(forResource: "PhotoEditorViewController", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: named, in: bundle, compatibleWith: nil)
        }
        return nil
    }
    
    class func bundle() -> Bundle {
        let podBundle = Bundle(for: PhotoEditorViewController.self)
        if let url = podBundle.url(forResource: "PhotoEditorViewController", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return bundle ?? podBundle
        }
        return podBundle
    }
}


@objc public protocol PhotoEditorDelegate {
    @objc func saveImageToLibrary(viewController: PhotoEditorViewController, image: UIImage)
    @objc func endEdited(viewController: PhotoEditorViewController, image: UIImage)
    @objc func editorCanceled()
}



@objc public extension UIViewController {
    
    @objc func presetPhotoEditorViewController(photo: UIImage, imageOk: UIImage? = nil, mainColor: UIColor? = nil, photoEditorDelegate: PhotoEditorDelegate? = nil, languageInt: Int = 1, saveImageToLibrary: ((PhotoEditorViewController, UIImage) -> Void)? = nil, endEdited: ((PhotoEditorViewController, UIImage) -> Void)? = nil, canceled: (() -> Void)? = nil) {
        EditMediaSetting.shared.languageApp = EditMediaLanguage(rawValue: languageInt) ?? EditMediaLanguage.en
        EditMediaSetting.shared.loadLocalized()
        
        let storyboard = UIStoryboard(name: "PhotoEditor", bundle: PreviewEditMedia.bundle())
        let vc = storyboard.instantiateViewController(withIdentifier: "PhotoEditorViewController") as! PhotoEditorViewController
        vc.saveImageToLibrary = saveImageToLibrary
        vc.endEdited = endEdited
        vc.canceled = canceled
        vc.imageOk = imageOk
        vc.photo = photo
        vc.mainColor = mainColor
        vc.checkVideoOrIamge = true
        vc.photoEditorDelegate = photoEditorDelegate
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
}

public final class PhotoEditorViewController: UIViewController, CropViewControllerDelegate {
    
    
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var videoViewContainer: UIView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoViewHeightConstraint: NSLayoutConstraint!
    
    // video output
    
    public var videoURL = URL(string: "")
    public var player: AVPlayer?
    public var playerController : AVPlayerViewController?
    public var output = AVPlayerItemVideoOutput()
    
    public var checkVideoOrIamge = Bool()
    
    //To hold the drawings and stickers
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    
    @IBOutlet weak var tickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteImageView: UIImageView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    public var photo: UIImage?
    public var stickers : [UIImage] = []
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    
    public var saveImageToLibrary: ((PhotoEditorViewController, UIImage) -> Void)? = nil
    public var endEdited: ((PhotoEditorViewController, UIImage) -> Void)? = nil
    public var canceled: (() -> Void)? = nil
    
    var imageOk: UIImage? = nil
    
    var mainColor: UIColor? = nil
    
    //
    var bottomSheetIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var opacity: CGFloat = 1.0
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageRotated: Bool = false
    var imageViewToPan: UIImageView?
    //
    
    //Register Custom font before we load XIB
    public override func loadView() {
        //registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        cancelButton.setImage(UIImage(named: "PEM-close-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        cancelButton.imageView?.contentMode = .scaleAspectFit
        cancelButton.tintColor = UIColor.white
        cancelButton.setTitle("", for: UIControl.State())
        
        drawButton.setImage(UIImage(named: "PEM-drawing-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        drawButton.imageView?.contentMode = .scaleAspectFit
        drawButton.tintColor = UIColor.white
        drawButton.setTitle("", for: UIControl.State())
        
        cropButton.setImage(UIImage(named: "PEM-crop-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        cropButton.imageView?.contentMode = .scaleAspectFit
        cropButton.tintColor = UIColor.white
        cropButton.setTitle("", for: UIControl.State())
        
        
        textButton.setImage(UIImage(named: "PEM-text-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        textButton.imageView?.contentMode = .scaleAspectFit
        textButton.tintColor = UIColor.white
        textButton.setTitle("", for: UIControl.State())
        
        self.imageOk = self.imageOk == nil ? UIImage(named: "PEM-sent-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) : nil
        continueButton.setImage(self.imageOk, for: UIControl.State())
        continueButton.imageView?.contentMode = .scaleAspectFit
        continueButton.tintColor = self.mainColor ?? UIColor.blue
        continueButton.setTitle("", for: UIControl.State())
        continueButton.backgroundColor = UIColor.white
        continueButton.layer.cornerRadius = 29
        continueButton.clipsToBounds = true
        
        saveButton.setImage(UIImage(named: "PEM-save-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        saveButton.imageView?.contentMode = .scaleAspectFit
        saveButton.tintColor = UIColor.white
        saveButton.setTitle("", for: UIControl.State())
        
        clearButton.setImage(UIImage(named: "PEM-clear-all-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        clearButton.imageView?.contentMode = .scaleAspectFit
        clearButton.tintColor = UIColor.white
        clearButton.setTitle("", for: UIControl.State())
        
        doneButton.setTitle("Save", for: UIControl.State())
        
        deleteView.layer.zPosition = -100
        deleteView.backgroundColor = UIColor.red
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.red.cgColor
        deleteView.clipsToBounds = true
        
        deleteImageView.tintColor = UIColor.white
        deleteImageView.image = UIImage(named: "PEM-delete-icon.png", in: PreviewEditMedia.bundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
        tickerButton.isHidden = true
        topGradient.isHidden = true
        bottomGradient.isHidden = true
       /*
        if switchCam {
            videoViewContainer.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            videoViewContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        */
        
        
  
        if checkVideoOrIamge {
            videoViewContainer.isHidden = true
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
          // tempImageView.contentMode = UIViewContentMode.scaleAspectFit
           canvasView.frame = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
           tempImageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
            
            imageView.isHidden = false
            imageView.image = photo

           // canvasView.layer.cornerRadius = 10
          //  self.canvasView.layer.masksToBounds = true
           
            
            
        } else {
            
            videoViewContainer.isHidden = true
            imageView.isHidden = true
            
            //imageView.image = (UIImage(named: "pic")!)
     
            player = AVPlayer(url: videoURL!)
            playerController = AVPlayerViewController()
            
            guard player != nil && playerController != nil else {
                return
            }
            playerController!.showsPlaybackControls = false
            
            playerController!.player = player!
            self.addChild(playerController!)
            self.view.addSubview(playerController!.view)
           // playerController!.view.layer.cornerRadius = 10
          //  playerController!.view.layer.masksToBounds = true
          
            tempImageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            
            playerController!.view.frame = view.frame
       
           view.insertSubview(playerController!.view, belowSubview: canvasView)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
            
        }
       
        
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        

        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
        
        configureCollectionView()
        bottomSheetVC = BottomSheetViewController(nibName: "BottomSheetViewController", bundle: Bundle(for: BottomSheetViewController.self))
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
        
        if checkVideoOrIamge {
            
        } else {
             player?.play()
        }
       
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: CMTime.zero)
            self.player!.play()
        }
    }
    
    func configureCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
        
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        
        if checkVideoOrIamge {
            if let finalImage = self.getFinalImage() {
                self.photoEditorDelegate?.saveImageToLibrary(viewController: self, image: finalImage)
                self.saveImageToLibrary?(self, finalImage)
            }
            
            
        } else {
            // Call function to convert and save video
            
            
//            let CIfilterName = "CIPhotoEffectInstant"
//            convertVideoToMP4(videoURL!, filterName: CIfilterName)
//            print("FILTER FOR VIDEO: \(CIfilterName)")
            
            convertVideoAndSaveTophotoLibrary(videoURL: videoURL!)
            
             // convertVideoAndSaveTophotoLibrary(videoURL: videoURL!)
            
//            addWatermark(outputURL: videoURL!) { exportSession in
//
//            }
          
        }
        
       
       
        ///To Share
        //let activity = UIActivityViewController(activityItems: [self.imageView.toImage()], applicationActivities: nil)
        //present(activity, animated: true, completion: nil)
        
    }
    

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
 
        tempImageView.image = nil
        //clear stickers and textviews
        for subview in tempImageView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        tempImageView.isUserInteractionEnabled = true
        hideToolbar(hide: false)
        isDrawing = false
    }
    
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    @IBAction func cropButtonTapped(_ sender: Any) {
        if let photo = self.photo {
            let cropViewController = CropViewController(croppingStyle: .default, image: photo)
            cropViewController.delegate = self
            let viewFrame = view.convert(self.canvasView.frame, to: navigationController?.view)
            cropViewController.presentAnimatedFrom(self, fromImage: nil, fromView: nil, fromFrame: viewFrame, angle: self.croppedAngle, toImageFrame: self.croppedRect) { () -> (Void) in
                
            } completion: { () -> (Void) in
                
            }
        }
        
    
    }
    
    
    //MARK: - CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        self.imageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        hideToolbar(hide: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        doneButton.isHidden = true
        hideToolbar(hide: false)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                if let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue{
                    
                    let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                    
                    if (endFrame.origin.y) >= UIScreen.main.bounds.size.height {
                        if UIDevice().userInterfaceIdiom == .phone {
                            switch UIScreen.main.nativeBounds.height {
                            case 1136:
                                print("iPhone 5 or 5S or 5C")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            case 1334:
                                print("iPhone 6/6S/7/8")
                                self.colorPickerViewBottomConstraint?.constant = 0.0 + 15
                            case 1920, 2208:
                                print("iPhone 6+/6S+/7+/8+")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            case 2436:
                                print("iPhone X")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            default:
                                print("unknown")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            }
                        }
                        
                     
                    } else {
                    
                        
                        switch UIScreen.main.nativeBounds.height {
                        case 1136:
                            print("iPhone 5 or 5S or 5C")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height
                        case 1334:
                            print("iPhone 6/6S/7/8")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height + 15
                        case 1920, 2208:
                            print("iPhone 6+/6S+/7+/8+")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height + 15
                        case 2436:
                            print("iPhone X")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height - 20
                        default:
                            print("unknown")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height
                        }
                        
                        
                    }
                    
                    
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: { self.view.layoutIfNeeded() },
                                   completion: nil)
                }
            }
        }
        
    }
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    

    
    
    
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.editorCanceled()
        self.canceled?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stickersButtonTapped(_ sender: Any) {
        addBottomSheetView()
    }
    
    @IBAction func textButtonTapped(_ sender: Any) {
        
        let textView = UITextView(frame: CGRect(x: 0, y: tempImageView.center.y, width: UIScreen.main.bounds.width, height: 50))
        
        //Text Attributes
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 40)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        //
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        self.tempImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }
    
    @IBAction func pencilButtonTapped(_ sender: Any) {
        isDrawing = true
        tempImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        hideToolbar(hide: true)
    }
    
    
    var bottomSheetVC: BottomSheetViewController!
    
    func addBottomSheetView() {
        bottomSheetIsVisible = true
        hideToolbar(hide: true)
        self.tempImageView.isUserInteractionEnabled = false
        bottomSheetVC.stickerDelegate = self
        
        for image in self.stickers {
            bottomSheetVC.stickers.append(image)
        }
        
       
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeBottomSheetView() {
        bottomSheetIsVisible = false
        self.tempImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.bottomSheetVC.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.bottomSheetVC.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.bottomSheetVC.view.removeFromSuperview()
            self.bottomSheetVC.removeFromParent()
            self.hideToolbar(hide: false)
        })
    }
    
    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
     
    }
    

    
    
    func addWatermark(outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let mixComposition = AVMutableComposition()
        print("hi")
        let asset = AVAsset(url: outputURL)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let timerange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))!
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        let watermarkImage = CIImage(image:self.tempImageView.toImage())
        let videoComposition = AVVideoComposition(asset: asset) { (filteringRequest) in
            let source = filteringRequest.sourceImage.clampedToExtent()
            watermarkFilter.setValue(source, forKey: "inputBackgroundImage")
            let transform = CGAffineTransform(translationX: filteringRequest.sourceImage.extent.width - (watermarkImage?.extent.width)! - 2, y: 0)
            watermarkFilter.setValue(watermarkImage?.transformed(by: transform), forKey: "inputImage")
            filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
            if exportSession.status == .completed {
                let outputURL: URL? = exportSession.outputURL
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                }) { saved, error in
                    if saved {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                        PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                            let newObj = avurlAsset as! AVURLAsset
                            print(newObj.url)
                            DispatchQueue.main.async(execute: {
                                print(newObj.url.absoluteString)
                            })
                        })
                        print (fetchResult!)
                    }
                }
            }
        }
    }
    
    
    
    private func getImageLayer(height: CGFloat) -> CALayer {
        let imglogo = UIImage(named: "bird_1.png")
        
        let imglayer = CALayer()
        imglayer.contents = imglogo?.cgImage
        imglayer.frame = CGRect(
            x: 0, y: height - imglogo!.size.height/4,
            width: imglogo!.size.width/4, height: imglogo!.size.height/4)
        imglayer.opacity = 0.6
        
        return imglayer
    }
    
    
    var exportSession:AVAssetExportSession!
    func convertVideoToMP4(_ vURL:URL, filterName:String)  {
        let videoAsset = AVURLAsset(url: videoURL!)
        
        // Apply Filter to Video
        var videoComposition = AVMutableVideoComposition()
        if filterName != "None" {
            let filter = CIFilter(name: filterName)!
            videoComposition = AVMutableVideoComposition(asset: videoAsset) { (request) in
                let source = request.sourceImage.clampedToExtent()
                filter.setValue(source, forKey: kCIInputImageKey)
                _ = CMTimeGetSeconds(request.compositionTime)
                let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
                request.finish(with: output, context: nil)
                print("OUTPUT CIIMAGE FILTERED: \(output.description)")
            }
        }
        
        exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory2.appendingPathComponent("video.mp4")
        deleteFile(filePath: filePath as NSURL)
        
        // Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do { try FileManager.default.removeItem(atPath: myDocumentPath)
            } catch let error { print(error) }
        }
        
        exportSession!.outputURL = filePath
        
        if filterName != "None" { exportSession.videoComposition = videoComposition }
        
        exportSession!.outputFileType = .mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: videoAsset.duration)
        exportSession?.timeRange = range
        
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch self.exportSession!.status {
            case .failed:
                print("ERROR ON CONVERSION TO MP4: \(self.exportSession!.error!.localizedDescription)")
            case .cancelled:
                print("Export canceled")
            case .completed:
                
                
                DispatchQueue.main.async {
                    if self.exportSession.status == .completed {
                        let outputURL: URL? = self.exportSession.outputURL
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                        }) { saved, error in
                            if saved {
                                let fetchOptions = PHFetchOptions()
                                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                                    let newObj = avurlAsset as! AVURLAsset
                                    print(newObj.url)
                                    DispatchQueue.main.async(execute: {
                                        print(newObj.url.absoluteString)
                                    })
                                })
                                print (fetchResult!)
                            }
                        }
                    }
                }
                
            default: break
            }
        })
    }
    

//
//    // Mark :- save a video photoLibrary
    func convertVideoAndSaveTophotoLibrary(videoURL: URL) {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory2.appendingPathComponent("video.mp4")
        deleteFile(filePath: filePath as NSURL)

        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do { try FileManager.default.removeItem(atPath: myDocumentPath)
            } catch let error { print(error) }
        }

        // File to composit
        let asset = AVURLAsset(url: videoURL as URL)
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)

        let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]


        // Rotate to potrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)

       
        let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform



        //fix orientation
        var videoAssetOrientation_  = UIImage.Orientation.up
        
        var isVideoAssetPortrait_  = false
        
        if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
            videoAssetOrientation_ = UIImage.Orientation.right
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
            videoAssetOrientation_ =  UIImage.Orientation.left
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
            videoAssetOrientation_ =  UIImage.Orientation.up
        }
        if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
            videoAssetOrientation_ = UIImage.Orientation.down;
        }
        
   
        transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
        transformer.setOpacity(0.0, at: asset.duration)

        
     

        
        //adjust the render size if neccessary
        var naturalSize: CGSize
        if(isVideoAssetPortrait_){
            naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
        } else {
            naturalSize = clipVideoTrack.naturalSize;
        }
        
      

        
        var renderWidth: CGFloat!
        var renderHeight: CGFloat!

        renderWidth = naturalSize.width
        renderHeight = naturalSize.height

        let parentlayer = CALayer()
        let videoLayer = CALayer()
        let watermarkLayer = CALayer()


        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderScale = 1.0
        
        
        
        watermarkLayer.contents = tempImageView.asImage().cgImage

       
        parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        videoLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)

        parentlayer.addSublayer(videoLayer)
        parentlayer.addSublayer(watermarkLayer)

 

        // Add watermark to video
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(60, preferredTimescale: 30))


        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]

        let exporter = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputFileType = AVFileType.mov
        exporter?.outputURL = filePath
        exporter?.videoComposition = videoComposition

        exporter!.exportAsynchronously(completionHandler: {() -> Void in
            if exporter?.status == .completed {
                let outputURL: URL? = exporter?.outputURL
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                }) { saved, error in
                    if saved {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                        PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                            let newObj = avurlAsset as! AVURLAsset
                            print(newObj.url)
                            DispatchQueue.main.async(execute: {
                                print(newObj.url.absoluteString)
                            })
                        })
                        print (fetchResult!)
                    }
                }
            }
        })


    }
    
   
    
    
  
    
    func deleteFile(filePath:NSURL) {
        guard FileManager.default.fileExists(atPath: filePath.path!) else {
            return
        }
        
        do { try FileManager.default.removeItem(atPath: filePath.path!)
        } catch { fatalError("Unable to delete file: \(error)") }
    }
    
    func getImageFrameInImageView(imageView : UIImageView) -> CGRect {
        
        if let image = imageView.image {
            let wi = image.size.width
            let hi = image.size.height

            let wv = imageView.frame.width
            let hv = imageView.frame.height

            let ri = hi / wi
            let rv = hv / wv

            var x, y, w, h: CGFloat

            if ri > rv {
                h = hv
                w = h / ri
                x = (wv / 2) - (w / 2)
                y = 0
            } else {
                w = wv
                h = w * ri
                x = 0
                y = (hv / 2) - (h / 2)
            }

            let scale = UIScreen.main.scale
            return CGRect(x: x * scale, y: y * scale, width: w * scale, height: h * scale)
        }
        return .zero
        
    }
    
    
    func getFinalImage() -> UIImage? {
        let image = canvasView.toImage()
        let rect = self.getImageFrameInImageView(imageView: self.imageView)
        if let cgImage = image.toCIImage()?.toCGImage(), let imageRef = cgImage.cropping(to: rect) {
            let croppedImage = UIImage(cgImage: imageRef)
            return croppedImage
        }
        return nil
        
    }
    
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if checkVideoOrIamge {
            if let finalImage = self.getFinalImage() {
                self.imageView.image = finalImage
                self.photoEditorDelegate?.endEdited(viewController: self, image: finalImage)
                self.endEdited?(self, finalImage)
            }
        } else {
            
            
        }
        
    }
    
    
    
}
 
 

extension PhotoEditorViewController: ColorDelegate {
    func chosedColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}

extension PhotoEditorViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            let oldFrame = textView.frame
            let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
        lastTextViewTransform =  textView.transform
        lastTextViewTransCenter = textView.center
        lastTextViewFont = textView.font!
        activeTextView = textView
        textView.superview?.bringSubviewToFront(textView)
        textView.font = UIFont(name: "Helvetica", size: 40)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = CGAffineTransform.identity
                        textView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
        }, completion: nil)
        
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
            else {
                return
        }
        activeTextView = nil
        textView.font = self.lastTextViewFont!
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = self.lastTextViewTransform!
                        textView.center = self.lastTextViewTransCenter!
        }, completion: nil)
    }
    
}

extension PhotoEditorViewController: StickerDelegate {
    
    func viewTapped(view: UIView) {
        self.removeBottomSheetView()
        view.center = tempImageView.center
        
        self.tempImageView.addSubview(view)
        //Gestures
        addGestures(view: view)
    }
    
    func imageTapped(image: UIImage) {
        self.removeBottomSheetView()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = tempImageView.center
        
        self.tempImageView.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
    }
    
    func bottomSheetDidDisappear() {
        bottomSheetIsVisible = false
        hideToolbar(hide: false)
    }
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(PhotoEditorViewController.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(PhotoEditorViewController.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(PhotoEditorViewController.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
    }
}

extension PhotoEditorViewController {
    
    //Resources don't load in main bundle we have to register the font
    func registerFont(){
        let bundle = Bundle(for: PhotoEditorViewController.self)
        let url =  bundle.url(forResource: "Eventtus-Icons", withExtension: "ttf")
        
        guard let fontDataProvider = CGDataProvider(url: url! as CFURL) else {
            return
        }
        let font = CGFont(fontDataProvider)
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font!, &error) else {
            return
        }
    }
}

