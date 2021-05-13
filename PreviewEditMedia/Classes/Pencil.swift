//
//  Pencil.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/26/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

extension PhotoEditorViewController {
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            swiped = true
            if let touch = touches.first {
                lastPoint = touch.location(in: self.tempImageView)
                bezierCurvePoints.append(lastPoint)
            }
        }
            //Hide stickersVC if clicked outside it
        else if bottomSheetIsVisible == true {
            if let touch = touches.first {
                let location = touch.location(in: self.view)
                if !bottomSheetVC.view.frame.contains(location) {
                    removeBottomSheetView()
                }
            }
        }
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            // 6
            /*
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasView)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                
                // 7
                lastPoint = currentPoint
            }
            */
            swiped = true
            if let touch = touches.first {
                let point = touch.location(in: canvasView)
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
                    
                }
                drawLine()
            }
            
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            swiped = false
            /*
            if !swiped {
                // draw a single point
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
            */
            
            drawLine()
            
            bezierCurvePoints.removeAll()
            bezierPathLine.removeAllPoints()
        }
        
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            context.setLineCap( CGLineCap.round)
            context.setLineWidth(5.0)
            context.setStrokeColor(drawColor.cgColor)
            context.setBlendMode( CGBlendMode.normal)
            // 4
            context.strokePath()
            // 5
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    
    private func drawLine() {
        UIGraphicsBeginImageContextWithOptions(tempImageView.frame.size, false, UIScreen.main.scale)
        
        /*
        context.setFillColor(color.cgColor)
        context.setStrokeColor(color.cgColor)
        context.setShadow(offset: CGSize(width:0, height: 0), blur: 20, color: color.cgColor)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(brush.radius * 2)
        
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        
        context.drawPath(using: .stroke)
        */
        if let context = UIGraphicsGetCurrentContext() {
            tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height))
            if(self.brushStyle == .glow) {
                context.setFillColor(drawColor.cgColor)
                context.setShadow(offset: CGSize(width:0, height: 0), blur: 1, color: drawColor.cgColor)
                
                context.setLineCap( CGLineCap.round)
                context.setLineWidth(self.drawLineWidth)
                context.setStrokeColor(UIColor.white.cgColor)
                context.setBlendMode( CGBlendMode.normal)
                context.addPath(bezierPathLine.cgPath)
      
                context.strokePath()
            } else {
                context.setLineCap( CGLineCap.round)
                context.setLineWidth(self.drawLineWidth)
                context.setStrokeColor(drawColor.cgColor)
                context.setBlendMode( CGBlendMode.normal)
                context.addPath(bezierPathLine.cgPath)
      
                context.strokePath()
            }
            
     
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
    }
    
    
    
}



