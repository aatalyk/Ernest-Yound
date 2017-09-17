//
//  Hints.swift
//  Contactis_Challenge
//
//  Created by ARKALYK AKASH on 7/30/17.
//  Copyright © 2017 ARKALYK AKASH. All rights reserved.
//
import Foundation
import UIKit

public enum Direction: Int {
    case Up
    case Down
    case Left
    case Right
    
    public var isX: Bool { return self == .Left || self == .Right }
    public var isY: Bool { return !isX }
}

extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}

public extension UIPanGestureRecognizer {
    
    public var direction: Direction? {
        let vel = velocity(in: view)
        let vertical = fabs(vel.y) > fabs(vel.x)
        switch (vertical, vel.x, vel.y) {
        case (true, _, let y) where y < 0: return .Up
        case (true, _, let y) where y > 0: return .Down
        case (false, let x, _) where x > 0: return .Right
        case (false, let x, _) where x < 0: return .Left
        default: return nil
        }
    }
}

enum Sizes{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let expandedViewHeight = Sizes.screenHeight/2.0
    static let compressedViewHeight : CGFloat = 83.0
    static let controlAndSidePointDifference : CGFloat = 10.0
    static let recordButtonWidth : CGFloat = 60.0
}

enum Operations{
    static let multiplication = "×"
    static let division = "÷"
    static let addition = "+"
    static let subtraction = "-"
}

struct Hints {
    static let recordInstructionText = "Press the record button below"
    static let stopInstructionText = "Just release your finger when you're done"
    static let errorInstructionText = "Please speak loudly and clearly."
    static let expressionPlaceHolderText = "Did you come up with your question?"
    static let expressionRecordingText = "Listening carefully..."
    static let computingText = "Ernying..."
    static let computingInstructionText = "Give me sec"
    static let errorText = "Could not hear you clearly, sorry"
}

extension UIColor{
    static let customPink = UIColor(red: 255/255.0, green: 229/255.0, blue: 3/255.0, alpha: 1.0)
    static let customPurple = UIColor(red: 144/255.0, green: 120/255.0, blue: 189/255.0, alpha: 1.0)
    static let customGray = UIColor(red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1.0)
}
