import SwiftUI
import QRCode

struct HistoryView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @Environment(\.dismiss) private var dismiss
    var onSelect: (SavedQRCode) -> Void
    @State private var selectedFilter: QRContentType?
    @State private var sortOrder: SortOrder = .newest
    @State private var searchText = ""
    
    enum SortOrder {
        case newest, oldest, name
        
        var text: String {
            switch self {
            case .newest: return "Newest First"
            case .oldest: return "Oldest First"
            case .name: return "By Name"
            }
        }
        
        var icon: String {
            switch self {
            case .newest: return "arrow.down.circle"
            case .oldest: return "arrow.up.circle"
            case .name: return "textformat.abc"
            }
        }
    }
    
    private var filteredQRCodes: [SavedQRCode] {
        let typeFiltered = selectedFilter == nil ? viewModel.savedQRCodes : viewModel.savedQRCodes.filter { $0.contentType == selectedFilter }
        
        let searchFiltered = searchText.isEmpty ? typeFiltered : typeFiltered.filter { qrCode in
            qrCode.name.localizedCaseInsensitiveContains(searchText) ||
            qrCode.url.localizedCaseInsensitiveContains(searchText)
        }
        
        return searchFiltered.sorted { first, second in
            switch sortOrder {
            case .newest:
                return first.createdAt > second.createdAt
            case .oldest:
                return first.createdAt < second.createdAt
            case .name:
                return first.name.localizedCompare(second.name) == .orderedAscending
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedQRCodes.isEmpty {
                    EmptyStateView()
                } else {
                    VStack(spacing: 0) {
                        // Search bar
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                TextField("Search QR codes...", text: $searchText)
                                    .textFieldStyle(.plain)
                                
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(8)
                            .background(.quaternary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding()
                        
                        // Filter chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(
                                    title: "All",
                                    isSelected: selectedFilter == nil,
                                    action: { selectedFilter = nil }
                                )
                                
                                ForEach(QRContentType.allCases) { type in
                                    FilterChip(
                                        title: type.title,
                                        icon: type.icon,
                                        isSelected: selectedFilter == type,
                                        action: { selectedFilter = type }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredQRCodes) { qrCode in
                                    HistoryItemView(qrCode: qrCode)
                                        .contextMenu {
                                            Button {
                                                onSelect(qrCode)
                                                dismiss()
                                            } label: {
                                                Label("Use this QR Code", systemImage: "arrow.counterclockwise")
                                            }
                                            
                                            Button(role: .destructive) {
                                                viewModel.deleteQRCode(qrCode)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .onTapGesture {
                                            onSelect(qrCode)
                                            dismiss()
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Códigos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort Order", selection: $sortOrder) {
                            Label("Newest First", systemImage: "arrow.down.circle")
                                .tag(SortOrder.newest)
                            Label("Oldest First", systemImage: "arrow.up.circle")
                                .tag(SortOrder.oldest)
                            Label("By Name", systemImage: "textformat.abc")
                                .tag(SortOrder.name)
                        }
                    } label: {
                        Image(systemName: sortOrder.icon)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? .blue : .gray.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("folder") // Add this image to your assets
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("Aún no hay códigos")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Los códigos guardados en tu colección aparecerán aquí")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct HistoryItemView: View {
    let qrCode: SavedQRCode
    
    private var contentTypeIcon: String {
        qrCode.contentType.icon
    }
    
    private var contentPreview: String {
        switch qrCode.contentType {
        case .url:
            if let host = URL(string: qrCode.url)?.host {
                return host
            }
            return qrCode.url
        case .text:
            let maxLength = 50
            if qrCode.url.count > maxLength {
                return qrCode.url.prefix(maxLength) + "..."
            }
            return qrCode.url
        case .wifi:
            if let data = qrCode.url.data(using: .utf8),
               let wifiData = try? JSONDecoder().decode(WifiNetwork.self, from: data) {
                return "Network: \(wifiData.ssid)"
            }
            return "Wi-Fi Network"
        case .contact:
            if let data = qrCode.url.data(using: .utf8),
               let contactInfo = try? JSONDecoder().decode(ContactInfo.self, from: data) {
                let name = "\(contactInfo.firstName) \(contactInfo.lastName)".trimmingCharacters(in: .whitespaces)
                return name.isEmpty ? "Contact Card" : name
            }
            return "Contact Card"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // QR Code Preview with full styling
            if let preview = generateStyledQRCode() {
                Image(uiImage: preview)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .background(qrCode.style.backgroundColor.color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: contentTypeIcon)
                                .foregroundStyle(.secondary)
                            Text(qrCode.contentType.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(qrCode.name)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text(contentPreview)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                
                Text(qrCode.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func generateStyledQRCode() -> UIImage? {
        guard let doc = try? QRCode.Document(
            utf8String: qrCode.url,
            errorCorrection: .quantize
        ) else { return nil }
        
        // Apply all saved styles
        doc.design.shape.eye = QRCodeHelpers.eyeShapeGenerator(for: qrCode.style.eyeShape)
        doc.design.shape.onPixels = QRCodeHelpers.pixelShape(for: qrCode.style.pixelStyle)
        
        // Configure corner style
        if let pixelGenerator = doc.design.shape.onPixels as? QRCode.PixelShape.RoundedPath {
            switch qrCode.style.cornerStyle {
            case .square:
                pixelGenerator.cornerRadiusFraction = 0
            case .rounded:
                pixelGenerator.cornerRadiusFraction = 0.5
            case .extraRounded:
                pixelGenerator.cornerRadiusFraction = 1.0
            }
        }
        
        // Set colors
        let backgroundColor = qrCode.style.backgroundColor.color
        let qrCodeColor = backgroundColor.isLight ? Color.black : Color.white
        
        doc.design.style.onPixels = QRCode.FillStyle.Solid(
            qrCodeColor.cgColor ?? CGColor(gray: 0, alpha: 1)
        )
        doc.design.style.background = QRCode.FillStyle.Solid(
            backgroundColor.cgColor ?? CGColor(gray: 1, alpha: 1)
        )
        
        // Add logo if present
        if let logoData = qrCode.style.logoData,
           let logoImage = UIImage(data: logoData),
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
        if let cgImage = try? doc.cgImage(CGSize(width: 200, height: 200)) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
} 
