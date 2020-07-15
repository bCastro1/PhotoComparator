//
//  Collage_Draw.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/6/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import Foundation
import UIKit

protocol Collage_Draw_Protocol {
    func disableButtonWithIndex(_ index: Int)
    func collageFinishCheck(_ areTilesFilled: Bool)
}

class Collage_Draw {
    
    private enum CollageLayout: String {
        case _2a = "2a"
        case _2b = "2b"
        case _3a = "3a"
        case _3b = "3b"
        case _3c = "3c"
        case _3d = "3d"
        case _4a = "4a"
        case _4b = "4b"
        case _4c = "4c"
        case _4d = "4d"
    }
    
    var delegate: Collage_Draw_Protocol!
    
    var chosenLayout: String = "" //which image model chosen; eg. 2a -> is two horizontal photos side by side
    var layoutIndex: Int = 0 //which index in given model

    var frameWidth: CGFloat = 0
    var frameHeight: CGFloat = 0
    var oneThirdValue: CGFloat = 0.333333
    var twoThirdValue: CGFloat = 0.666666

    var firstPhoto: UIImage?
    var secondPhoto: UIImage?
    var thirdPhoto: UIImage?
    var fourthPhoto: UIImage?
    
    var collageObjects: [Collage_Model] = []//cropped photo, index and metaData
    
    var finalCollage: UIImage?
    var collageFinishCheck: Bool = true
    
//    //MARK: Date Label component
//    var dateLabel: UILabel = {
//        var label = UILabel()
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 5
//        label.layer.borderColor = UIColor.white.cgColor
//        label.layer.borderWidth = 1
//        label.textColor = .white
//        label.backgroundColor = .darkGray
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.5
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    //MARK: Initialization
    init (frameWidth: CGFloat, frameHeight: CGFloat, layout: String){
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.chosenLayout = layout
    }
    
    //MARK: return collage image
    func getCurrentCollageImage() -> UIImage{
        collageFinishCheck = true
        for image in collageObjects {
            switch image.index {
            case 0:
                let photoData = collageObjects.first(where: {$0.index == 0})//getting photo with the zero index
                firstPhoto = photoData?.photoWithMetaData.photo
                delegate.disableButtonWithIndex(0)
                break
            case 1:
                let photoData = collageObjects.first(where: {$0.index == 1})
                secondPhoto = photoData?.photoWithMetaData.photo
                delegate.disableButtonWithIndex(1)
                break
            case 2:
                let photoData = collageObjects.first(where: {$0.index == 2})
                thirdPhoto = photoData?.photoWithMetaData.photo
                delegate.disableButtonWithIndex(2)
                break
            case 3:
                let photoData = collageObjects.first(where: {$0.index == 3})
                fourthPhoto = photoData?.photoWithMetaData.photo
                delegate.disableButtonWithIndex(3)
                break
            default:
                print("err in collage_Draw")
                break
            }
        }
        
        drawImages()
        return finalCollage ?? UIImage(named: "4a_b")!
    }



    //MARK: Draw images
    private func drawImages(){
        let size = CGSize(width: self.frameWidth, height: self.frameHeight)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        switch chosenLayout {
        //MARK: 2a
        case "2a":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth/2, height: frameHeight))
            } else { collageFinishCheck = false }
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: frameWidth/2, y: 0, width: frameWidth/2, height: frameHeight))
            } else { collageFinishCheck = false }
        //MARK: 2b
        case "2b":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight/2))
            } else { collageFinishCheck = false }
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: 0, y: frameHeight/2, width: frameWidth, height: frameHeight/2))
            } else { collageFinishCheck = false }
        
        //MARK: 3a
        case "3a":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth/2, height: frameHeight/2))
            } else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: frameWidth/2, y: 0, width: frameWidth/2, height: frameHeight/2))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: 0, y: frameHeight/2, width: frameWidth, height: frameHeight/2))
            } else { collageFinishCheck = false }
            
        //MARK: 3b
        case "3b":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight/2))
            } else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: 0, y: frameHeight/2, width: frameWidth/2, height: frameHeight/2))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: frameWidth/2, y: frameHeight/2, width: frameWidth/2, height: frameHeight/2))
            } else { collageFinishCheck = false }
        
        //MARK: 3c
        case "3c":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth * oneThirdValue, height: frameHeight))
            } else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: frameWidth * oneThirdValue, y: 0, width: frameWidth * oneThirdValue, height: frameHeight))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: frameWidth * twoThirdValue, y: 0, width: frameWidth * oneThirdValue, height: frameHeight))
            } else { collageFinishCheck = false }
        
        //MARK: 3d
        case "3d":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: 0, y: frameHeight * oneThirdValue, width: frameWidth, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: 0, y: frameHeight * twoThirdValue, width: frameWidth, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
        
        //MARK: 4a
        case "4a":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth/2, height: frameHeight/2))
            }  else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: frameWidth/2, y: 0, width: frameWidth/2, height: frameHeight/2))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: 0, y: frameHeight/2, width: frameWidth/2, height: frameHeight/2))
            } else { collageFinishCheck = false }
            
            if (fourthPhoto != nil){
                fourthPhoto!.draw(in: CGRect(x: frameWidth/2, y: frameHeight/2, width: frameWidth/2, height: frameHeight/2))
            } else { collageFinishCheck = false }
        
        //MARK: 4b
        case "4b":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth * oneThirdValue, height: frameHeight * twoThirdValue))
            }  else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: frameWidth * oneThirdValue, y: 0, width: frameWidth * oneThirdValue, height: frameHeight * twoThirdValue))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: frameWidth * twoThirdValue, y: 0, width: frameWidth * oneThirdValue, height: frameHeight * twoThirdValue))
            } else { collageFinishCheck = false }
            
            if (fourthPhoto != nil){
                fourthPhoto!.draw(in: CGRect(x: 0, y: frameHeight * twoThirdValue, width: frameWidth, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
            
        //MARK: 4c
        case "4c":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth * oneThirdValue, height: frameHeight * oneThirdValue))
            }  else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: frameWidth * oneThirdValue, y: 0, width: frameWidth * oneThirdValue, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: frameWidth * twoThirdValue, y: 0, width: frameWidth * oneThirdValue, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
            
            if (fourthPhoto != nil){
                fourthPhoto!.draw(in: CGRect(x: 0, y: frameHeight * oneThirdValue, width: frameWidth, height: frameHeight * twoThirdValue))
            } else { collageFinishCheck = false }
            
        //MARK: 4d
        case "4d":
            if (firstPhoto != nil){
                firstPhoto!.draw(in: CGRect(x: 0, y: 0, width: frameWidth * oneThirdValue, height: frameHeight * oneThirdValue))
            }  else { collageFinishCheck = false }
            
            if (secondPhoto != nil){
                secondPhoto!.draw(in: CGRect(x: 0, y: frameHeight * oneThirdValue, width: frameWidth * oneThirdValue, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
            
            if (thirdPhoto != nil){
                thirdPhoto!.draw(in: CGRect(x: 0, y: frameHeight * twoThirdValue, width: frameWidth * oneThirdValue, height: frameHeight * oneThirdValue))
            } else { collageFinishCheck = false }
            
            if (fourthPhoto != nil){
                fourthPhoto!.draw(in: CGRect(x: frameWidth * oneThirdValue, y: 0, width: frameWidth * twoThirdValue, height: frameHeight))
            } else { collageFinishCheck = false }
        default:
            collageFinishCheck = false
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        finalCollage = newImage
        delegate.collageFinishCheck(collageFinishCheck)
        
        if (collageFinishCheck){
            //finished collage, draw date label
            setAndDrawDateLabel()
        }
    }
    
    
    
    //MARK: Draw Date Label
    private func setAndDrawDateLabel(){
        
        if let firstDate = self.collageObjects.first?.photoWithMetaData.date,
            let secondDate = self.collageObjects.last?.photoWithMetaData.date
        {
            var earlierDate: NSDate!
            var laterDate: NSDate!
            if (firstDate < secondDate){
                earlierDate = firstDate
                laterDate = secondDate
            }
            else {
                earlierDate = secondDate
                laterDate = firstDate
            }
            let dateText = "(\(earlierDate.formatDate()) - \(laterDate.formatDate())) \n\(timeFrom(lhs: earlierDate, rhs: laterDate))"
            
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(CGSize(width: self.frameWidth, height: self.frameHeight), false, scale)
            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            
            let textFontAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeColor: UIColor.black,
                NSAttributedString.Key.strokeWidth: -6,
                NSAttributedString.Key.paragraphStyle : paragraphStyle,
                ] as [NSAttributedString.Key : Any]
            let dateString = NSAttributedString(string: dateText, attributes: textFontAttributes)
            let largestSize = CGSize(width: self.frameWidth-30, height: .greatestFiniteMagnitude)
            
            finalCollage!.draw(in: CGRect(origin: CGPoint.zero, size: finalCollage!.size))
            
            let framesetter = CTFramesetterCreateWithAttributedString(dateString)
            let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, largestSize, nil)

//            let labelXpos = self.frameWidth/2 - textSize.width/2
//            let labelYpos = self.frameHeight/2 - textSize.height/2
            let (xPos,yPos) = returnLabelPosition(textSize: textSize)
            
            let rect = CGRect(x: xPos, y: yPos, width: textSize.width, height: textSize.height)
            dateText.draw(in: rect, withAttributes: textFontAttributes)

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            finalCollage = newImage
        }
    }
    
    private func returnLabelPosition(textSize: CGSize)-> (LabelXpos: CGFloat, LabelYpos: CGFloat){
        // ( labelXpos : labelYpos )
        var x = CGFloat()
        var y = CGFloat()
        
        switch chosenLayout {
            //MARK: 2a
            case "2a":
                //bottom middle
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight-25) - textSize.height/2
            
            //MARK: 2b
            case "2b":
                //centered
                x = self.frameWidth/2 - textSize.width/2
                y = self.frameHeight/2 - textSize.height/2
            
            //MARK: 3a
            case "3a":
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight/2-25) - textSize.height/2
            
            //MARK: 3b
            case "3b":
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight/2+25) - textSize.height/2

            //MARK: 3c
            case "3c":
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight-25) - textSize.height/2
            
            //MARK: 3d
            case "3d":
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight-25) - textSize.height/2
            
            //MARK: 4a
            case "4a":
                x = self.frameWidth/2 - textSize.width/2
                y = self.frameHeight/2 - textSize.height/2
            
            //MARK: 4b
            case "4b":
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight*0.66) - textSize.height/2
            
            //MARK: 4c
            case "4c":
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight*0.33) - textSize.height/2

            //MARK: 4d
            case "4d":
                x = self.frameWidth/2 - textSize.width/2
                y = (self.frameHeight-25) - textSize.height/2

            default:
                x = self.frameWidth/2 - textSize.width/2
                y = self.frameHeight/2 - textSize.height/2
        }
        
        return (x,y)
    }
}

