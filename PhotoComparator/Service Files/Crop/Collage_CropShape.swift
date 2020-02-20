//
//  Collage_CropShape.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/4/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import Foundation


struct Collage_CropShape{
    let cropShape: String
    let index: Int
    
    init(cropShape: String, index: Int){
        self.cropShape = cropShape
        self.index = index
    }
    
    
    
    func returnCropShape() -> CROP_TYPE{
        var cropType: CROP_TYPE?
        
        switch cropShape {
        //MARK: 2 pic layouts
        case "2a":
            switch index {
            case 0,1:
                cropType = CROP_TYPE.rect3x4
            default:
                cropType = CROP_TYPE.square
            }
            break
        case "2b":
            switch index {
            case 0,1:
                cropType = CROP_TYPE.rect4x3
            default:
                cropType = CROP_TYPE.square
            }
            break
        //MARK: 3 pic layouts
        case "3a":
            switch index {
            case 0,1:
                cropType = CROP_TYPE.square
            case 2:
                cropType = CROP_TYPE.rect4x3
            default:
                cropType = CROP_TYPE.square
            }
        case "3b":
            switch index {
            case 0:
                cropType = CROP_TYPE.rect4x3
            case 1,2:
                cropType = CROP_TYPE.square
            default:
                cropType = CROP_TYPE.square
            }
        case "3c":
            switch index {
            case 0,1,2:
                cropType = CROP_TYPE.rect2x5
            default:
                cropType = CROP_TYPE.square
            }
        case "3d":
            switch index {
            case 0,1,2:
                cropType = CROP_TYPE.rect5x2
            default:
                cropType = CROP_TYPE.square
            }
        //MARK: 4 pic layouts
        case "4a":
            switch index {
            case 0,1,2:
                cropType = CROP_TYPE.square
            default:
                cropType = CROP_TYPE.square
            }
        case "4b":
            switch index {
            case 0,1,2:
                cropType = CROP_TYPE.rect2x5
            case 3:
                cropType = CROP_TYPE.rect5x2
            default:
                cropType = CROP_TYPE.square
            }
        case "4c":
            switch index {
            case 0,1,2:
                cropType = CROP_TYPE.square
            case 3:
                cropType = CROP_TYPE.rect4x3
            default:
                cropType = CROP_TYPE.square
            }
        case "4d":
            switch index {
            case 0,1,2:
                cropType = CROP_TYPE.square
            case 3:
                cropType = CROP_TYPE.rect3x4
            default:
                cropType = CROP_TYPE.square
            }
        default:
            cropType = CROP_TYPE.square
        }
        
        return cropType!
    }
}
