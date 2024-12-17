import SwiftUI

struct ContentTypeSelector: View {
    @Binding var contentType: QRContentType
    let backgroundColor: Color
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(QRContentType.allCases) { type in
                    Button {
                        contentType = type
                    } label: {
                        HStack {
                            Image(systemName: type.icon)
                            Text(type.title)
                        }
                        .font(.subheadline)
                        .foregroundStyle(contentType == type ? textColor : textColor.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(contentType == type ? backgroundColor : backgroundColor.opacity(0.3))
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
} 