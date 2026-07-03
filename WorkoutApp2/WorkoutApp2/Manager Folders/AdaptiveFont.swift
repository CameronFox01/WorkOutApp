//
//  AdaptiveFont.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 7/2/26.
//


import SwiftUI

func isIPad() -> Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

struct AdaptiveFont {
    
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static func title() -> Font {
        isIPad ? .largeTitle : .title
    }

    static func title2() -> Font {
        isIPad ? .title : .title2
    }

    static func title3() -> Font {
        isIPad ? .title2 : .title3
    }

    static func headline() -> Font {
        isIPad ? .title3 : .headline
    }

    static func subheadline() -> Font {
        isIPad ? .headline : .subheadline
    }

    static func body() -> Font {
        isIPad ? .title3 : .body
    }

    static func caption() -> Font {
        isIPad ? .subheadline : .caption
    }

    static func caption2() -> Font {
        isIPad ? .caption : .caption2
    }
}

struct AdaptiveSize {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // Spacing
    static func spacing(_ phone: CGFloat, iPad: CGFloat? = nil) -> CGFloat {
        isIPad ? (iPad ?? phone * 1.5) : phone
    }

    // Padding
    static func padding(_ phone: CGFloat, iPad: CGFloat? = nil) -> CGFloat {
        isIPad ? (iPad ?? phone * 1.5) : phone
    }

    // Frame sizes
    static func frame(_ phone: CGFloat, iPad: CGFloat? = nil) -> CGFloat {
        isIPad ? (iPad ?? phone * 1.5) : phone
    }

    // Max width — useful for cards and forms
    static func maxWidth(phone: CGFloat = .infinity, iPad: CGFloat = 700) -> CGFloat {
        isIPad ? iPad : phone
    }

    // Icon/image sizes
    static func iconSize(_ phone: CGFloat, iPad: CGFloat? = nil) -> CGFloat {
        isIPad ? (iPad ?? phone * 1.4) : phone
    }

    // Corner radius
    static func cornerRadius(_ phone: CGFloat, iPad: CGFloat? = nil) -> CGFloat {
        isIPad ? (iPad ?? phone * 1.2) : phone
    }
}

extension UIFont {
    static var adaptiveTitle3: UIFont {
        AdaptiveFont.isIPad
            ? .preferredFont(forTextStyle: .title2)
            : .preferredFont(forTextStyle: .title3)
    }

    static var adaptiveHeadline: UIFont {
        AdaptiveFont.isIPad
            ? .preferredFont(forTextStyle: .title3)
            : .preferredFont(forTextStyle: .headline)
    }
}

extension View {
    func adaptiveFont(_ style: AdaptiveFont.Style) -> some View {
        self.font(style.font)
    }
}

extension AdaptiveFont {
    enum Style {
        case title, title2, title3, headline, subheadline, body, caption, caption2

        var font: Font {
            let isIPad = AdaptiveFont.isIPad
            switch self {
            case .title:       return isIPad ? .largeTitle : .title
            case .title2:      return isIPad ? .title : .title2
            case .title3:      return isIPad ? .title2 : .title3
            case .headline:    return isIPad ? .title3 : .headline
            case .subheadline: return isIPad ? .headline : .subheadline
            case .body:        return isIPad ? .title3 : .body
            case .caption:     return isIPad ? .subheadline : .caption
            case .caption2:    return isIPad ? .caption : .caption2
            }
        }
    }
}

extension Font {
    static var adaptiveBody: Font {
        AdaptiveFont.isIPad ? .title3 : .body
    }
    static var adaptiveHeadline: Font {
        AdaptiveFont.isIPad ? .title2 : .headline
    }
    static var adaptiveTitle: Font {
        AdaptiveFont.isIPad ? .largeTitle : .title
    }
    static var adaptiveTitle2: Font {
        AdaptiveFont.isIPad ? .title : .title2
    }
    static var adaptiveTitle3: Font {
        AdaptiveFont.isIPad ? .title2 : .title3
    }
    static var adaptiveSubheadline: Font {
        AdaptiveFont.isIPad ? .headline : .subheadline
    }
    static var adaptiveCaption: Font {
        AdaptiveFont.isIPad ? .subheadline : .caption
    }
    static var adaptiveCaption2: Font {
        AdaptiveFont.isIPad ? .caption : .caption2
    }
}

extension CGFloat {
    static var adaptiveRowHeight: CGFloat {
        AdaptiveFont.isIPad ? 60 : 44
    }
    static var adaptivePickerHeight: CGFloat {
        AdaptiveFont.isIPad ? 160 : 100
    }
    static var adaptivePadding: CGFloat {
        AdaptiveFont.isIPad ? 24 : 16
    }
    static var adaptiveSpacing: CGFloat {
        AdaptiveFont.isIPad ? 24 : 16
    }
    static var adaptiveIconSize: CGFloat {
        AdaptiveFont.isIPad ? 32 : 22
    }
    static var adaptiveCornerRadius: CGFloat {
        AdaptiveFont.isIPad ? 20 : 14
    }
    static var adaptiveFormMaxWidth: CGFloat {
        AdaptiveFont.isIPad ? 700 : .infinity
    }
}
