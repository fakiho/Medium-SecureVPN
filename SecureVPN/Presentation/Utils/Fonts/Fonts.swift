//
//  Fonts.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/13/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import SwiftUI

class Fonts {
    private static let defaultFontName = "Montserrat"
    
    class func defaultFont(ofSize: CGFloat, weight: UIFont.Weight? = nil) -> UIFont {
        if let weight = weight {
            var fontName = defaultFontName
            switch weight {
            case .black:
                fontName += "-Black"
            case .bold:
                fontName += "-Bold"
            case .heavy:
                fontName += "-ExtraBold"
            case .light:
                fontName += "-Thin"
            case .medium:
                fontName += "-Medium"
            case .regular:
                fontName += "-Regular"
            case .semibold:
                fontName += "-SemiBold"
            case .thin:
                fontName += "-ExtraLight"
            default:
                break
            }
            var descriptor = UIFontDescriptor(name: defaultFontName, size: ofSize)
               descriptor = descriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: weight]])
             return UIFont(name: fontName, size: ofSize) ?? UIFont.systemFont(ofSize: ofSize)
        }
        return UIFont(name: defaultFontName, size: ofSize) ?? UIFont.systemFont(ofSize: ofSize)
    }
    
    class var boldFont: UIFont { defaultFont(ofSize: 15, weight: .bold) }
    
    class var blackFont: UIFont { defaultFont(ofSize: 30, weight: .black) }
    
    class var mediumFont: UIFont { defaultFont(ofSize: 15, weight: .medium) }
    
    class var semiBoldFont: UIFont { defaultFont(ofSize: 15, weight: .semibold) }
    
    class var lightFont: UIFont { defaultFont(ofSize: 15, weight: .light) }
    
    class var smallFont: UIFont { defaultFont(ofSize: 13, weight: .regular) }
    
    class var titleMediumFont: UIFont { defaultFont(ofSize: 32, weight: .medium) }
    
    class var subtitleRegularFont: UIFont { defaultFont(ofSize: 14, weight: .regular) }
    
    class var boldButtonFont: UIFont { defaultFont(ofSize: 25, weight: .bold)}
    
    class var titleFont: UIFont { defaultFont(ofSize: 20, weight: .bold)}
}

@available(iOS 13.0, *)
class SwiftUIFonts {
    
    private static let defaultFontName = "Montserrat"
    
    class func defaultFont(ofSize: CGFloat, weight: Font.Weight? = nil) -> Font {
        if let weight = weight {
            return Font.custom(defaultFontName, size: ofSize).weight(weight)
        }
        return Font.custom(defaultFontName, size: ofSize)
    }
    
    class var defaultFont: Font { return defaultFont(ofSize: 16)}
    
    class var mediumFont: Font { return defaultFont(ofSize: 16, weight: .medium) }
    
    class var callout: Font {return defaultFont(ofSize: 13, weight: .bold)}
    
    class var titleSemi: Font { return  defaultFont(ofSize: 24, weight: .semibold) }
    
    class var textFieldLabelFont: Font { return defaultFont(ofSize: 13, weight: .medium)}
    
    class var subtitleFont: Font { return defaultFont(ofSize: 13, weight: .regular)}
    
    class var smallFont: Font { return defaultFont(ofSize: 11, weight: .regular)}
    
    class var boldFont: Font { return defaultFont(ofSize: 17, weight: .bold)}
    
    class var mediumSmallFont: Font { return defaultFont(ofSize: 12, weight: .medium)}
    
    class var extraBold: Font { return defaultFont(ofSize: 16, weight: .heavy)}
    
    class var semiBoldSmall: Font {return defaultFont(ofSize: 13, weight: .semibold)}
    
    class var largeBoldTitle: Font { return defaultFont(ofSize: 30, weight: .bold)}
    
    class var largeMedium: Font { return defaultFont(ofSize: 24, weight: .medium)}
    
    class var semiBoldMedium: Font { return defaultFont(ofSize: 18, weight: .semibold)}
}
