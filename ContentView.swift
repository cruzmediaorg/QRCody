//
//  ContentView.swift
//  QRcody
//
//  Created by Luis De la Cruz on 16/12/24.
//

import SwiftUI
import QRCode
import Contacts
import ContactsUI
import UIKit

struct ContentView: View {
    @State private var url = ""
    @State private var qrCode: Image?
    @State private var cornerStyle = QRCornerStyle.rounded
    @State private var pixelStyle = QRPixelStyle.square
    @State private var backgroundColor: Color
    @State private var selectedLogo: UIImage?
    @Environment(\.colorScheme) var colorScheme
    @State private var eyeShape = QREyeShape.circle
    @StateObject private var viewModel = QRCodeViewModel()
    @State private var showingHistory = false
    @State private var contentType: QRContentType = .url
    @State private var wifiNetwork = WifiNetwork(ssid: "", password: "", isHidden: false, securityType: .wpa)
    @State private var plainText = ""
    @State private var selectedContact: CNContact?
    @State private var showingContactPicker = false
    @State private var logoImage: UIImage?
    @State private var showingImagePicker = false
    
    // Add initializer to set random color
    init() {
        let colors: [Color] = [
            .mint, .teal, .cyan, .blue,
            .indigo, .purple, .pink,
            .orange, .yellow, .green
        ]
        _backgroundColor = State(initialValue: colors.randomElement() ?? .blue)
    }
    
    // Compute QR code color based on background brightness
    private var qrCodeColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    private func generateQRCode(from string: String) -> Image? {
        guard !string.isEmpty else { return nil }
        
        guard let doc = try? QRCode.Document(
            utf8String: string,
            errorCorrection: .quantize
        ) else { return nil }
        
        // Configure eye shape first
        doc.design.shape.eye = eyeShapeGenerator(for: eyeShape)
        
        // Configure pixel shape
        doc.design.shape.onPixels = pixelShape(for: pixelStyle)
        
        // Configure corner style
        if let pixelGenerator = doc.design.shape.onPixels as? QRCode.PixelShape.RoundedPath {
            switch cornerStyle {
            case .square:
                pixelGenerator.cornerRadiusFraction = 0
            case .rounded:
                pixelGenerator.cornerRadiusFraction = 0.5
            case .extraRounded:
                pixelGenerator.cornerRadiusFraction = 1.0
            }
        }
        
        // Set colors - using computed QR code color
        doc.design.style.onPixels = QRCode.FillStyle.Solid(
            qrCodeColor.cgColor ?? CGColor(gray: 0, alpha: 1)
        )
        doc.design.style.background = QRCode.FillStyle.Solid(
            backgroundColor.cgColor ?? CGColor(gray: 1, alpha: 1)
        )
        
        // Add logo if present
        if let logoImage,
           let cgImage = logoImage.cgImage {
            // Create a centered logo that takes up 20% of the QR code
            let path = CGPath(
                ellipseIn: CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2),
                transform: nil
            )
            let logo = QRCode.LogoTemplate(
                image: cgImage,
                path: path,
                inset: 12
            )
            doc.logoTemplate = logo
        }
        
        // Generate image
        if let cgImage = try? doc.cgImage(CGSize(width: 800, height: 800)) {
            return Image(uiImage: UIImage(cgImage: cgImage))
        }
        
        return nil
    }
    
    // Helper function to get pixel shape
    private func pixelShape(for style: QRPixelStyle) -> QRCodePixelShapeGenerator {
        switch style {
        case .square:
            return QRCode.PixelShape.Square()
        case .circle:
            return QRCode.PixelShape.Circle()
        case .roundedPath:
            return QRCode.PixelShape.RoundedPath()
        case .curvePixel:
            return QRCode.PixelShape.CurvePixel()
        case .flower:
            return QRCode.PixelShape.Flower()
        case .heart:
            return QRCode.PixelShape.Heart()
        case .star:
            return QRCode.PixelShape.Star()
        case .horizontal:
            return QRCode.PixelShape.Horizontal()
        case .vertical:
            return QRCode.PixelShape.Vertical()
        case .wave:
            return QRCode.PixelShape.Wave()
        }
    }
    
    // Helper function to get eye shape
    private func eyeShapeGenerator(for shape: QREyeShape) -> QRCodeEyeShapeGenerator {
        switch shape {
        case .square:
            return QRCode.EyeShape.Square()
        case .circle:
            return QRCode.EyeShape.Circle()
        case .roundedRect:
            return QRCode.EyeShape.RoundedRect()
        case .leaf:
            return QRCode.EyeShape.Leaf()
        case .shield:
            return QRCode.EyeShape.Shield()
        case .fireball:
            return QRCode.EyeShape.Fireball()
        case .eye:
            return QRCode.EyeShape.Eye()
        }
    }
    
    private func loadSavedQRCode(_ savedQRCode: SavedQRCode) {
        // First clear all content fields
        url = ""
        plainText = ""
        wifiNetwork = WifiNetwork(ssid: "", password: "", isHidden: false, securityType: .wpa)
        selectedContact = nil
        
        // Switch to the correct content type
        contentType = savedQRCode.contentType
        
        // Load the appropriate content based on type
        switch savedQRCode.contentType {
        case .url:
            url = savedQRCode.url
        case .text:
            plainText = savedQRCode.url
        case .wifi:
            print("Loading WiFi data: \(savedQRCode.url)") // Debug print
            // Parse the WIFI: format string
            let wifiString = savedQRCode.url
            var ssid = ""
            var password = ""
            var isHidden = false
            var securityType: WifiNetwork.SecurityType = .wpa
            
            // Split the string by semicolons and process each component
            let components = wifiString.components(separatedBy: ";")
            for component in components {
                if component.starts(with: "S:") {
                    ssid = String(component.dropFirst(2))
                } else if component.starts(with: "P:") {
                    password = String(component.dropFirst(2))
                } else if component.starts(with: "T:") {
                    let type = String(component.dropFirst(2))
                    switch type {
                    case "WPA": securityType = .wpa
                    case "WEP": securityType = .wep
                    case "nopass": securityType = .noPassword
                    default: break
                    }
                } else if component.starts(with: "H:") {
                    isHidden = String(component.dropFirst(2)) == "true"
                }
            }
            
            // Create new WifiNetwork object
            wifiNetwork = WifiNetwork(
                ssid: ssid,
                password: password,
                isHidden: isHidden,
                securityType: securityType
            )
        case .contact:
            // Parse vCard format
            let vCardString = savedQRCode.url
            var firstName = ""
            var lastName = ""
            var email = ""
            var phone = ""
            
            // Split into lines and process each line
            let lines = vCardString.components(separatedBy: "\n")
            for line in lines {
                if line.starts(with: "FN:") {
                    // Split full name into first and last
                    let fullName = String(line.dropFirst(3))
                    let nameParts = fullName.components(separatedBy: " ")
                    firstName = nameParts.first ?? ""
                    lastName = nameParts.dropFirst().joined(separator: " ")
                } else if line.starts(with: "TEL:") {
                    phone = String(line.dropFirst(4))
                } else if line.starts(with: "EMAIL:") {
                    email = String(line.dropFirst(6))
                }
            }
            
            // Create contact
            let contact = CNMutableContact()
            contact.givenName = firstName
            contact.familyName = lastName
            if !email.isEmpty {
                contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: email as NSString)]
            }
            if !phone.isEmpty {
                contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phone))]
            }
            selectedContact = contact
        }
        
        // Load the styling
        backgroundColor = savedQRCode.style.backgroundColor.color
        cornerStyle = savedQRCode.style.cornerStyle
        pixelStyle = savedQRCode.style.pixelStyle
        eyeShape = savedQRCode.style.eyeShape
        
        // Load the logo if present
        if let logoData = savedQRCode.style.logoData {
            logoImage = UIImage(data: logoData)
        } else {
            logoImage = nil
        }
        
        // Update the QR code display
        updateQRCode()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MainContentView(
                    url: $url,
                    qrCode: $qrCode,
                    backgroundColor: $backgroundColor,
                    cornerStyle: $cornerStyle,
                    pixelStyle: $pixelStyle,
                    eyeShape: $eyeShape,
                    contentType: $contentType,
                    wifiNetwork: $wifiNetwork,
                    plainText: $plainText,
                    selectedContact: $selectedContact,
                    showingContactPicker: $showingContactPicker,
                    logoImage: $logoImage,
                    showingImagePicker: $showingImagePicker,
                    updateQRCode: updateQRCode,
                    onSave: saveToHistory
                )
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingHistory = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(backgroundColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(
                viewModel: viewModel,
                onSelect: loadSavedQRCode
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $logoImage, onSelect: {
                updateQRCode()
            })
        }
    }
    
    private func updateQRCode() {
        let content = generateContentString()
        guard !content.isEmpty else {
            qrCode = nil
            return
        }
        qrCode = generateQRCode(from: content)
    }
    
    private func saveCurrentQRCode() {
        let style = QRCodeStyle(
            backgroundColor: CodableColor(color: backgroundColor),
            cornerStyle: cornerStyle,
            pixelStyle: pixelStyle,
            eyeShape: eyeShape,
            logoData: logoImage?.pngData()
        )
        viewModel.saveCurrentQRCode(url: url, style: style, contentType: contentType)
    }
    
    // Add this function to save QR codes to history
    private func saveToHistory() {
        let style = QRCodeStyle(
            backgroundColor: CodableColor(color: backgroundColor),
            cornerStyle: cornerStyle,
            pixelStyle: pixelStyle,
            eyeShape: eyeShape,
            logoData: logoImage?.pngData()
        )
        let content = generateContentString()
        viewModel.saveCurrentQRCode(url: content, style: style, contentType: contentType)
    }
    
    private func generateContentString() -> String {
        switch contentType {
        case .url:
            return url
        case .wifi:
            return wifiNetwork.generateQRString()
        case .text:
            return plainText
        case .contact:
            if let contact = selectedContact {
                return ContactInfo(contact: contact).generateQRString()
            }
            return ""
        }
    }
}

// Replace the MainContentView with this updated version
private struct MainContentView: View {
    @Binding var url: String
    @Binding var qrCode: Image?
    @Binding var backgroundColor: Color
    @Binding var cornerStyle: QRCornerStyle
    @Binding var pixelStyle: QRPixelStyle
    @Binding var eyeShape: QREyeShape
    @Binding var contentType: QRContentType
    @Binding var wifiNetwork: WifiNetwork
    @Binding var plainText: String
    @Binding var selectedContact: CNContact?
    @Binding var showingContactPicker: Bool
    @Binding var logoImage: UIImage?
    @Binding var showingImagePicker: Bool
    let updateQRCode: () -> Void
    let onSave: () -> Void
    
    // Update gradient colors calculation
    private var gradientColors: [Color] {
        let color = UIColor(backgroundColor)
        var (h, s, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        // Create subtle variations by slightly shifting hue and using opacity
        let color1 = Color(hue: Double((h + 0.02).truncatingRemainder(dividingBy: 1.0)),
                          saturation: Double(s * 0.95),
                          brightness: Double(b))
        
        let color2 = Color(hue: Double((h - 0.02).truncatingRemainder(dividingBy: 1.0)),
                          saturation: Double(s * 0.9),
                          brightness: Double(b))
        
        return [
            color1.opacity(0.8),
            backgroundColor,
            color2.opacity(0.8)
        ]
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground(backgroundColor: backgroundColor)
            
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.7)
            .ignoresSafeArea()
            
            MainScrollContent(
                url: $url,
                qrCode: $qrCode,
                backgroundColor: $backgroundColor,
                cornerStyle: $cornerStyle,
                pixelStyle: $pixelStyle,
                eyeShape: $eyeShape,
                contentType: $contentType,
                wifiNetwork: $wifiNetwork,
                plainText: $plainText,
                selectedContact: $selectedContact,
                showingContactPicker: $showingContactPicker,
                logoImage: $logoImage,
                showingImagePicker: $showingImagePicker,
                updateQRCode: updateQRCode,
                onSave: onSave
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// Add these new supporting views
private struct BackgroundGradientView: View {
    let backgroundColor: Color
    @State private var t: Float = 0.0
    @State private var timer: Timer?
    
    func sinInRange(_ range: ClosedRange<Float>, offset: Float, timeScale: Float, t: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(timeScale * t + offset)
    }
    
    var body: some View {
        GeometryReader { geometry in
            MeshGradient(
                width: Int(geometry.size.width),
                height: Int(geometry.size.height),
                points: [
                    // Top row (fixed)
                    .init(-0.5, -0.5), .init(0.5, -0.5), .init(1.5, -0.5),
                    
                    // Middle row (animated)
                    [sinInRange(-0.8...(-0.2), offset: 0.439, timeScale: 0.342, t: t),
                     sinInRange(0.3...0.7, offset: 3.42, timeScale: 0.984, t: t)],
                    [sinInRange(0.1...0.8, offset: 0.239, timeScale: 0.084, t: t),
                     sinInRange(0.2...0.8, offset: 5.21, timeScale: 0.242, t: t)],
                    [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.084, t: t),
                     sinInRange(0.4...0.8, offset: 0.25, timeScale: 0.642, t: t)],
                    
                    // Bottom row (animated)
                    [sinInRange(-0.8...0.0, offset: 1.439, timeScale: 0.442, t: t),
                     sinInRange(1.4...1.9, offset: 3.42, timeScale: 0.984, t: t)],
                    [sinInRange(0.3...0.6, offset: 0.339, timeScale: 0.784, t: t),
                     sinInRange(1.0...1.2, offset: 1.22, timeScale: 0.772, t: t)],
                    [sinInRange(1.0...1.5, offset: 0.939, timeScale: 0.056, t: t),
                     sinInRange(1.3...1.7, offset: 0.47, timeScale: 0.342, t: t)]
                ],
                colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.9),
                    backgroundColor.opacity(0.8),
                    backgroundColor.opacity(0.95),
                    backgroundColor.opacity(0.85),
                    backgroundColor.opacity(0.75),
                    backgroundColor.opacity(0.9),
                    backgroundColor.opacity(0.8),
                    backgroundColor.opacity(0.7)
                ],
                background: backgroundColor
            )
        }
        .ignoresSafeArea()
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                t += 0.02
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

private struct MainScrollContent: View {
    @Binding var url: String
    @Binding var qrCode: Image?
    @Binding var backgroundColor: Color
    @Binding var cornerStyle: QRCornerStyle
    @Binding var pixelStyle: QRPixelStyle
    @Binding var eyeShape: QREyeShape
    @Binding var contentType: QRContentType
    @Binding var wifiNetwork: WifiNetwork
    @Binding var plainText: String
    @Binding var selectedContact: CNContact?
    @Binding var showingContactPicker: Bool
    @Binding var logoImage: UIImage?
    @Binding var showingImagePicker: Bool
    let updateQRCode: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        ScrollView {
            mainContent
                .padding()
                .frame(maxWidth: .infinity)
        }
        .modifier(ContentChangeModifier(
            updateQRCode: updateQRCode,
            contentType: contentType,
            url: url,
            wifiNetwork: wifiNetwork,
            plainText: plainText,
            selectedContact: selectedContact,
            backgroundColor: backgroundColor,
            cornerStyle: cornerStyle,
            pixelStyle: pixelStyle,
            eyeShape: eyeShape,
            logoImage: logoImage
        ))
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 20)
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 32) {
            typeSelector
            inputSection
            previewSection
            customizationSection
            actionButtons
        }
    }
    
    private var typeSelector: some View {
        ContentTypeSelector(contentType: $contentType, backgroundColor: backgroundColor)
            .padding(.vertical)
    }
    
    private var previewSection: some View {
        QRCodePreviewSection(
            qrCode: qrCode,
            backgroundColor: backgroundColor,
            contentType: contentType
        )
    }
    
    private var customizationSection: some View {
        CustomizationSection(
            backgroundColor: $backgroundColor,
            cornerStyle: $cornerStyle,
            pixelStyle: $pixelStyle,
            eyeShape: $eyeShape,
            logoImage: $logoImage,
            showingImagePicker: $showingImagePicker
        )
    }
    
    private var actionButtons: some View {
        ActionButtonsSection(
            qrCode: qrCode,
            backgroundColor: backgroundColor,
            onSave: onSave
        )
    }
    
    @ViewBuilder
    private var inputSection: some View {
        switch contentType {
        case .url:
            URLInputSection(
                url: $url,
                onSubmit: updateQRCode,
                backgroundColor: backgroundColor
            )
        case .wifi:
            WifiInputView(
                network: $wifiNetwork,
                backgroundColor: backgroundColor
            )
        case .text:
            TextInputView(
                text: $plainText,
                backgroundColor: backgroundColor
            )
        case .contact:
            ContactPickerView(
                selectedContact: $selectedContact,
                showingContactPicker: $showingContactPicker,
                backgroundColor: backgroundColor
            )
        }
    }
}

// Add this modifier to handle content changes
private struct ContentChangeModifier: ViewModifier {
    let updateQRCode: () -> Void
    let contentType: QRContentType
    let url: String
    let wifiNetwork: WifiNetwork
    let plainText: String
    let selectedContact: CNContact?
    let backgroundColor: Color
    let cornerStyle: QRCornerStyle
    let pixelStyle: QRPixelStyle
    let eyeShape: QREyeShape
    let logoImage: UIImage?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: contentType) { _, _ in updateQRCode() }
            .onChange(of: url) { _, _ in updateQRCode() }
            .onChange(of: wifiNetwork) { _, _ in updateQRCode() }
            .onChange(of: plainText) { _, _ in updateQRCode() }
            .onChange(of: selectedContact) { _, _ in updateQRCode() }
            .onChange(of: backgroundColor) { _, _ in updateQRCode() }
            .onChange(of: cornerStyle) { _, _ in updateQRCode() }
            .onChange(of: pixelStyle) { _, _ in updateQRCode() }
            .onChange(of: eyeShape) { _, _ in updateQRCode() }
            .onChange(of: logoImage) { _, _ in updateQRCode() }
    }
}

// MARK: - Preview Sections
struct QRCodePreviewSection: View {
    let qrCode: Image?
    let backgroundColor: Color
    let contentType: QRContentType
    
    var body: some View {
        VStack {
            if let qrCode {
                qrCode
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 280)
                    .background(backgroundColor)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            } else {
                PlaceholderView(contentType: contentType, backgroundColor: backgroundColor)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Action Buttons Section
struct ActionButtonsSection: View {
    let qrCode: Image?
    let backgroundColor: Color
    @State private var showToast = false
    let onSave: () -> Void
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                // Save Button
                Button {
                    if let qrCode {
                        saveQRCode(qrCode)
                        onSave()
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .foregroundStyle(textColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .disabled(qrCode == nil)
                .buttonStyle(.plain)
                
                // Share Button
                Button {
                    if let qrCode {
                        shareQRCode(qrCode)
                    }
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(textColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .disabled(qrCode == nil)
                .buttonStyle(.plain)
            }
            
            // Toast overlay
            if showToast {
                Toast(
                    message: "QR Code saved to Photos",
                    icon: "checkmark.circle.fill",
                    isPresented: $showToast
                )
                .zIndex(1)
                .offset(y: -60)
            }
        }
        .animation(.spring(duration: 0.5), value: showToast)
    }
    
    private func saveQRCode(_ image: Image) {
        let renderer = ImageRenderer(content: image
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: 1024, height: 1024)
        )
        
        renderer.scale = 3.0
        
        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            showToast = true
            
            // Hide toast after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        }
    }
    
    private func shareQRCode(_ image: Image) {
        let renderer = ImageRenderer(content: image
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: 1024, height: 1024)
        )
        
        renderer.scale = 3.0
        
        if let uiImage = renderer.uiImage {
            let activityVC = UIActivityViewController(
                activityItems: [uiImage],
                applicationActivities: nil
            )
            
            // Get the current window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                activityVC.popoverPresentationController?.sourceView = rootViewController.view
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
}

// MARK: - Color Customization View
struct ColorCustomizationView: View {
    @Binding var backgroundColor: Color
    @State private var showingColorPicker = false
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color")
                .font(.headline)
                .foregroundStyle(textColor)
            
            Button {
                showingColorPicker = true
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Background Color")
                            .font(.subheadline)
                            .foregroundStyle(textColor.opacity(0.7))
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(backgroundColor)
                                .frame(width: 30, height: 30)
                                .overlay {
                                    Circle()
                                        .strokeBorder(textColor.opacity(0.4))
                                }
                            
                            Text("Select Color")
                                .font(.body)
                                .foregroundStyle(textColor)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(textColor.opacity(0.7))
                }
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showingColorPicker) {
                CustomColorPicker(selectedColor: $backgroundColor)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    ContentView()
}

