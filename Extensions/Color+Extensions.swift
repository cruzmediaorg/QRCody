import SwiftUI
import UIKit

extension Color {
    var cgColor: CGColor? {
        let uiColor = UIColor(self)
        return uiColor.cgColor
    }
    
    // Calculate relative luminance
    var brightness: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Using relative luminance formula
        return (0.299 * red + 0.587 * green + 0.114 * blue)
    }
    
    // Determine if color is light or dark
    var isLight: Bool {
        return brightness > 0.5
    }
} 