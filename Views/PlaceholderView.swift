import SwiftUI

struct PlaceholderView: View {
    let contentType: QRContentType
    let backgroundColor: Color

    private var placeholderText: String {
        switch contentType {
        case .url:
            return "Enter URL to generate QR code"
        case .wifi:
            return "Enter WiFi details to generate QR code"
        case .text:
            return "Enter text to generate QR code"
        case .contact:
            return "Select a contact to generate QR code"
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(backgroundColor)
            .frame(width: 280, height: 280)
            .overlay {
                VStack(spacing: 16) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 60))
                        .foregroundStyle(backgroundColor.isLight ? .black : .white)

                    Text(placeholderText)
                        .foregroundStyle(backgroundColor.isLight ? .black : .white)
                        .font(.callout)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    PlaceholderView(contentType: .url, backgroundColor: .blue)
} 