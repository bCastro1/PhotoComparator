//
//  CropFunctionHelpers.swift
//  PhotoComparator
//  Posted on January 7, 2016 by Deb S
//  https://appsbydeb.wordpress.com/2016/01/07/ios-swift-simple-image-cropping-app/
//  Edited by Brendan Castro

import Foundation
import UIKit

struct xy {
   var x: CGFloat!
   var y: CGFloat!
   mutating func xy(_x: CGFloat , _y: CGFloat){
      self.x = _x
      self.y = _y
   }
}

enum CROP_TYPE{
   case square, rect3x2,  rect2x3,  rect3x4,  rect4x3,  rect2x5,  rect5x2, square2x1, square1x2
    static let divs = [square : 1, rect3x2 : 5, rect2x3 : 5,rect3x4 : 7, rect4x3 : 7, rect2x5 : 7,rect5x2 : 7, square2x1 : 2, square1x2 : 2]
   static let muls = [
    square : xy(x: 0.5, y: 0.5),
    rect3x2 : xy(x: 3/5, y: 2/5),
    rect2x3 : xy(x: 2/5, y: 2/5),
    rect3x4 : xy(x: 3/7, y: 4/7),
    rect4x3 : xy(x: 4/7, y: 3/7),
    rect2x5 : xy(x: 2/7, y: 5/7),
    rect5x2 : xy(x: 5/7, y: 2/7),
    square2x1 : xy(x: 0.5, y: 1),
    square1x2 : xy(x: 1, y: 0.5)
    ]
    
   static let names = [
    square : " 1:1 ",
    rect3x2 : " 3:2 ",
    rect2x3 : " 2:3 ",
    rect3x4 : " 3:4 ",
    rect4x3 : " 4:3 ",
    rect2x5 : " 2:5 ",
    rect5x2 : " 5:2 ",
    square2x1 : " 2:1 ",
    square1x2 : " 1:2 "
    ]
    
   func Div()-> Int{
      if let ret = CROP_TYPE.divs[self]{
         return ret
      }else{
         return -1
      }
   }
   func Muls()-> xy{
      if let ret = CROP_TYPE.muls[self]{
          return ret
      }else{
          return xy(x: 0.5,y: 0.5)
      }
   }
   func Name()-> String{
      if let ret = CROP_TYPE.names[self]{
         return ret
      }else{
         return "n.a."
      }
   }
}

struct CROP_OPTIONS {
   var Height: CGFloat!
   var Width: CGFloat!
   var Center: CGPoint!
}

struct FRAME {
   var Height: CGFloat!
   var Width: CGFloat!
}

var  _cropOptions: CROP_OPTIONS!

