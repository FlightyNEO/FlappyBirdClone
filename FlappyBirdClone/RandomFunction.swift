//
//  RandomFunction.swift
//  FlappyBirdClone
//
//  Created by Arkadiy Grigoryanc on 28.01.17.
//  Copyright © 2017 Arkadiy Grigoryanc. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat {
    
    public static func random() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        
        return CGFloat.random() * (max - min) + min
        
    }
    
}
