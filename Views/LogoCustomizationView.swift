import SwiftUI
import UIKit

struct LogoCustomizationView: View {
    @Binding var logoImage: UIImage?
    @Binding var showingImagePicker: Bool
    let backgroundColor: Color
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Logo")
                .font(.headline)
                .foregroundStyle(textColor)
            
            Button {
                if logoImage != nil {
                    logoImage = nil
                } else {
                    showingImagePicker = true
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Center Logo")
                            .font(.subheadline)
                            .foregroundStyle(textColor.opacity(0.7))
                        
                        HStack(spacing: 8) {
                            if let logoImage {
                                Image(uiImage: logoImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .strokeBorder(textColor.opacity(0.4))
                                    }
                            } else {
                                Circle()
                                    .fill(backgroundColor)
                                    .frame(width: 30, height: 30)
                                    .overlay {
                                        Image(systemName: "plus")
                                            .foregroundStyle(textColor.opacity(0.7))
                                    }
                                    .overlay {
                                        Circle()
                                            .strokeBorder(textColor.opacity(0.4))
                                    }
                            }
                            
                            Text(logoImage == nil ? "Add Logo" : "Remove Logo")
                                .font(.body)
                                .foregroundStyle(textColor)
                        }
                    }
                    
                    Spacer()
                    
                    if logoImage == nil {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(textColor.opacity(0.7))
                    } else {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                    }
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
        }
    }
} 