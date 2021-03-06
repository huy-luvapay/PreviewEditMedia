//
//  ViewController.swift
//  PreviewEditMedia
//
//  Created by huy-luvapay on 04/22/2021.
//  Copyright (c) 2021 huy-luvapay. All rights reserved.
//

import UIKit
import PreviewEditMedia

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentEditPhoto() {
        self.presetPhotoEditorViewController(photo: UIImage(named: "photo3.png")!, languageInt: 2) { (viewController, image) in
            self.imageView.image = image
            viewController.dismiss(animated: true, completion: nil)
        } canceled: {
        }

    }
    
    
    @IBAction func showPressed() {
        self.presentEditPhoto()

    }
    

}




class LineHolderView: UIView {
    
    private var bezierPathLine: UIBezierPath!
    private var bufferImage: UIImage?

    private var bezierCurvePoints: [CGPoint] = []
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        initializeView()
    }
    
    override func draw(_ rect: CGRect) {
        bufferImage?.draw(in: rect)
        drawLine()
    }
    
    private func drawLine() {
        
        UIColor.red.setStroke()
        bezierPathLine.stroke()
    }
    
    private func initializeView() {
        
        isMultipleTouchEnabled = false
        
        bezierPathLine = UIBezierPath()
        bezierPathLine.lineWidth = 4
        
        self.backgroundColor = UIColor.clear
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(_:)))
        addGestureRecognizer(panGesture)
        
    }
    
    @objc func viewDragged(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.location(in: self)
        
        if point.x < 0 || point.x > frame.width || point.y < 0 || point.y > frame.height {
            return
        }
        
        switch sender.state {
            
        case .began:
            bezierCurvePoints.append(point)
            break
            
        case .changed:
            
            bezierCurvePoints.append(point)

            if bezierCurvePoints.count == 5 {
                

                // Calculate center point of 3rd and 5th point
                let x1 = bezierCurvePoints[2].x
                let y1 = bezierCurvePoints[2].y
                
                let x2 = bezierCurvePoints[4].x
                let y2 = bezierCurvePoints[4].y
                
                // Replace 4th point with the calculated center point
                bezierCurvePoints[3] = CGPoint(x: (x1 + x2) / 2, y: (y1 + y2) / 2)
                
                // Draw arc between 1st and 4th point
                bezierPathLine.move(to: bezierCurvePoints[0])
                bezierPathLine.addCurve(to: bezierCurvePoints[3], controlPoint1: bezierCurvePoints[1], controlPoint2: bezierCurvePoints[2])
                
                let point1 = bezierCurvePoints[3]
                let point2 = bezierCurvePoints[4]
                
                bezierCurvePoints.removeAll()
                
                // Last two points will be starting two points for next arc.
                bezierCurvePoints.append(point1)
                bezierCurvePoints.append(point2)
                
                setNeedsDisplay()
            }
            
            break
            
        case .ended:
            
            saveBufferImage()
            
            bezierCurvePoints.removeAll()
            bezierPathLine.removeAllPoints()
            break
        default:
            break
        }
    }
    
    private func saveBufferImage() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        if bufferImage == nil {
            let fillPath = UIBezierPath(rect: self.bounds)
            UIColor.clear.setFill()
            fillPath.fill()
        }
        bufferImage?.draw(at: .zero)
        drawLine()
        bufferImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
