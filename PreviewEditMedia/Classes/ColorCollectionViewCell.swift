//
//  ColorCollectionViewCell.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/1/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!
   
    
    @IBOutlet weak var selectedInsideView: UIView!
    
    @IBOutlet weak var selectedColorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectedInsideView.layer.cornerRadius = 12
        self.selectedInsideView.layer.borderWidth = 2
        self.selectedInsideView.layer.borderColor = UIColor.white.cgColor
        self.selectedInsideView.clipsToBounds = true
        self.selectedInsideView.backgroundColor = UIColor.black
        
        self.selectedColorView.layer.cornerRadius = 15
        self.selectedColorView.layer.borderWidth = 2
        self.selectedColorView.layer.borderColor = UIColor.white.cgColor
        self.selectedColorView.isHidden = true
        colorView.layer.cornerRadius = 11
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

    }
    
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            self.selectedColorView.isHidden = !newValue
            if newValue {
                super.isSelected = true
            } else if newValue == false {
                super.isSelected = false
            }
        }
    }
    

}
