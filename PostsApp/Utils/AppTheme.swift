import UIKit

enum AppTheme {
    // Primary accent color for selected items and interactive elements
    static let accent: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBlue
        } else {
            return UIColor.blue
        }
    }()

    // Surface/background color for bars and cards
    static let surface: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.secondarySystemBackground
        } else {
            return UIColor(white: 0.97, alpha: 1.0)
        }
    }()

    // Secondary text color for unselected tab items
    static let textSecondary: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor.darkGray
        }
    }()

    // Background color for primary view surfaces
    static let background: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()

    // Typography used across the app
    enum Font {
        static var displayBold: UIFont {
            if let font = UIFont(name: "HelveticaNeue-Bold", size: 34) {
                return font
            }
            return UIFont.boldSystemFont(ofSize: 34)
        }

        static var bodyRegular: UIFont {
            if let font = UIFont(name: "HelveticaNeue", size: 16) {
                return font
            }
            return UIFont.systemFont(ofSize: 16)
        }
    }
}
