import SwiftUI
import UIKit

struct CustomizationSection: View {
    @Binding var backgroundColor: Color
    @Binding var cornerStyle: QRCornerStyle
    @Binding var pixelStyle: QRPixelStyle
    @Binding var eyeShape: QREyeShape
    @Binding var logoImage: UIImage?
    @Binding var showingImagePicker: Bool
    @State private var showingStyleSheet = false
    @State private var selectedStyleType: StyleType = .corner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ColorCustomizationView(backgroundColor: $backgroundColor)
            
            LogoCustomizationView(
                logoImage: $logoImage,
                showingImagePicker: $showingImagePicker,
                backgroundColor: backgroundColor
            )
            
            StyleButtonsView(
                cornerStyle: cornerStyle,
                pixelStyle: pixelStyle,
                eyeShape: eyeShape,
                showSheet: $showingStyleSheet,
                selectedStyleType: $selectedStyleType,
                backgroundColor: backgroundColor
            )
        }
        .sheet(isPresented: $showingStyleSheet) {
            StyleBottomSheet(
                cornerStyle: $cornerStyle,
                pixelStyle: $pixelStyle,
                eyeShape: $eyeShape,
                styleType: selectedStyleType,
                backgroundColor: backgroundColor
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
} 