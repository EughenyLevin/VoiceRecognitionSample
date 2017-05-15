//
//  LETextView.swift
//  SpeechRecognitionTest
//
//  Created by Evgheny on 15.05.17.
//  Copyright © 2017 Eugheny_Levin. All rights reserved.
//

import UIKit
import Speech

@IBDesignable

class LETextView: UITextView {

    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layer.borderColor  = UIColor(white: 231/255, alpha:1).cgColor
        self.layer.borderWidth  = 0.7
        self.layer.cornerRadius = 5
        
    }


}
