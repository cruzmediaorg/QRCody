import SwiftUI

struct URLInputSection: View {
    @Binding var url: String
    var onSubmit: () -> Void
    @Environment(\.colorScheme) var colorScheme
    let backgroundColor: Color
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("URL")
                .font(.headline)
                .foregroundStyle(textColor)
            
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "link")
                        .foregroundStyle(textColor.opacity(0.7))
                    
                    TextField("Enter URL", text: $url)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .foregroundStyle(textColor)
                        .tint(textColor)
                        .onChange(of: url) { _, _ in
                            onSubmit()
                        }
                        .submitLabel(.done)
                    
                    if !url.isEmpty {
                        Button {
                            url = ""
                            onSubmit()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(textColor.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Button {
                    // Paste from clipboard
                    if let clipboardString = UIPasteboard.general.string {
                        url = clipboardString
                        onSubmit()
                    }
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundStyle(textColor)
                        .padding(12)
                        .background(backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
        }
    }
}

#Preview {
    URLInputSection(
        url: .constant("https://example.com"),
        onSubmit: {},
        backgroundColor: .blue
    )
    .padding()
    .background(Color.gray.opacity(0.1))
} 