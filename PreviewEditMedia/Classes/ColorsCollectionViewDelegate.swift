//
//  ColorsCollectionViewDelegate.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/1/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

protocol ColorDelegate {
    func chosedColor(color: UIColor, at index: Int)
}

class ColorsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var colorDelegate : ColorDelegate?
    
    let colors = [UIColor.darkGray, UIColor.gray, UIColor.lightGray, UIColor.white, UIColor.blue, UIColor.green, UIColor.red, UIColor.yellow,
                  UIColor.orange, UIColor.purple, UIColor.cyan, UIColor.brown, UIColor.purple]
    
    override init() {
        super.init()
    }
    
    var stickerDelegate : StickerDelegate?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorDelegate?.chosedColor(color: colors[indexPath.item], at: indexPath.item)
    
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
        cell.colorView.backgroundColor = colors[indexPath.item]
       
        /*
        cell.layer.cornerRadius = cell.frame.width / 2
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.white.cgColor
        */
        return cell
    }
    
}
