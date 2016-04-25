//
//  Theme.swift
//  Air-End
//
//  Created by Aaron B on 4/5/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit

struct Theme {
    enum Colors: UInt32 {
        case RedColor = 0
        case BlueColor = 1
        case YellowColor = 2
        case GreenColor = 3
        case PinkColor = 4
        case PurpleColor = 5
        case OrangeColor = 6
        case RedBackgroundColor = 7
        case BackgroundColor = 8
        case LightForegroundColor = 9
        case NavigationBarColor = 10
        case NavigationBarFontColor = 11
        case ButtonColor = 12
        case LabelColor = 13
        case SegmentedControlColor = 14

        
        static let allValues = [RedColor, BlueColor, YellowColor, GreenColor, PinkColor, PurpleColor, OrangeColor, RedBackgroundColor, BackgroundColor, LightForegroundColor, NavigationBarColor,NavigationBarFontColor, ButtonColor, LabelColor, SegmentedControlColor]
        
        var color: UIColor {
            switch self {
            case .RedColor: return UIColor(r:255, g: 51, b: 51)
            case .BlueColor: return UIColor(r: 0, g: 51, b: 255)
            case .YellowColor: return UIColor(r: 255, g: 255, b: 51)
            case .GreenColor: return UIColor(r: 51, g: 255, b: 51)
            case .PinkColor: return UIColor(r: 255, g: 51, b: 255)
            case .PurpleColor: return UIColor(r: 155, g: 51, b: 255)
            case .OrangeColor: return UIColor(r: 255, g: 155, b: 51)
            case .RedBackgroundColor: return UIColor(r: 210, g: 0, b: 0)
            case .BackgroundColor: return UIColor(r:255, g:152, b:0)
            case .LightForegroundColor: return UIColor(r:255, g:183, b:77)
            case .NavigationBarColor: return UIColor(r:239 ,g:108, b:0)
            case .NavigationBarFontColor: return UIColor.whiteColor()
            case .ButtonColor: return UIColor(r: 210, g: 0, b: 0)
            case .LabelColor: return UIColor(r:255, g:193, b:7)
            case .SegmentedControlColor: return UIColor(r:255, g:69, b:7)
            }
        }
    }
    
    static func randomColor() -> Colors {
                let maxValue = Colors.SegmentedControlColor.rawValue
                let randomValue = arc4random_uniform(maxValue)
                return Colors(rawValue: randomValue)!
            }
    
    enum Fonts {
        case TitleTypeFace
        case BoldTitleTypeFace
        case NormalTextTypeFaceLato
        case NavigationBarTypeFace
        case BoldNavigationBarTypeFace
        case BoldItalicNavigationBarTypeFace
        case NormalTextTypeFaceSimplifica
        
        var font: UIFont {
            switch self{
            case .TitleTypeFace: return UIFont(name: "Lato-Regular", size: 18)!
            case .BoldTitleTypeFace: return UIFont(name: "Lato-Bold", size: 17)!
            case .NormalTextTypeFaceLato: return UIFont(name: "Lato-Thin", size: 18)!
            case .NavigationBarTypeFace: return UIFont(name: "Glamor-Regular", size: 16)!
            case .BoldNavigationBarTypeFace: return UIFont(name: "Glamor-Bold", size: 25)!
            case .BoldItalicNavigationBarTypeFace: return UIFont(name: "Glamor-BoldExtendedItalic", size: 25)!
            case .NormalTextTypeFaceSimplifica: return UIFont(name: "Simplifica", size: 40)!
            }
        }
    }
}