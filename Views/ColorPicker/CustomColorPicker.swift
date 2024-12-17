import SwiftUI

struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var opacity: Double = 1.0
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging = false
    
    let presetColors: [Color] = [
        .green, .red, .orange, .yellow,
        .mint, .teal, .cyan, .blue,
        .indigo, .purple, .pink, .brown,
        .gray, .black, .white
    ]
    
    // Add these colors for the gradient
    let gradientColors: [Color] = [
        .red, .orange, .yellow, .green,
        .mint, .cyan, .blue, .indigo,
        .purple, .pink, .red
    ]
    
    // Add this function for random color generation
    private func generateRandomColor() -> Color {
        let x = Double.random(in: 0...1)
        let y = Double.random(in: 0...1)
        return getColorAt(x: x, y: y)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Color preview area
                    ColorPickerGradient(
                        selectedColor: $selectedColor,
                        gradientColors: gradientColors,
                        isDragging: $isDragging
                    )
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .overlay {
                        if !isDragging {
                            Text("Press and drag to select color")
                                .foregroundStyle(.white)
                                .font(.headline)
                                .shadow(radius: 2)
                        }
                    }
                    
                    // Preset colors with selected color as first item
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRESETS")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Selected color with shuffle functionality
                                Button {
                                    let newColor = generateRandomColor()
                                    selectedColor = newColor
                                    isDragging = true
                                } label: {
                                    Circle()
                                        .fill(selectedColor)
                                        .frame(width: 44 , height: 44)
                                        .overlay {
                                            Circle()
                                                .strokeBorder(.white.opacity(0.2))
                                            Image(systemName: "shuffle")
                                                .foregroundStyle(.white)
                                                .shadow(radius: 2)
                                        }
                                        .shadow(color: .black.opacity(0.1), radius: 2)
                                }
                                
                                // Preset colors
                                ForEach(presetColors, id: \.self) { color in
                                    Button {
                                        selectedColor = color
                                        isDragging = true
                                    } label: {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(.white.opacity(0.2))
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getColorAt(x: Double, y: Double) -> Color {
        let normalizedX = max(0, min(1, x))
        let normalizedY = max(0, min(1, y))
        
        let colorCount = Double(gradientColors.count - 1)
        let baseIndex = Int(normalizedX * colorCount)
        let nextIndex = min(baseIndex + 1, gradientColors.count - 1)
        let colorFraction = normalizedX * colorCount - Double(baseIndex)
        
        let baseColor = UIColor(gradientColors[baseIndex])
        let nextColor = UIColor(gradientColors[nextIndex])
        
        var (h1, s1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (h2, s2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        baseColor.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)
        nextColor.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)
        
        let h = h1 + (h2 - h1) * colorFraction
        let s = 1.0
        let b = max(0.3, 1.0 - (normalizedY * 0.7))
        
        return Color(hue: Double(h), saturation: Double(s), brightness: Double(b))
    }
}

struct ColorPickerGradient: View {
    @Binding var selectedColor: Color
    let gradientColors: [Color]
    @Binding var isDragging: Bool
    @State private var dragLocation: CGPoint = .zero
    
    private let baseColors: [Color] = [
        .red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink
    ]
    
    // Add this function to find position for a given color
    private func findPositionForColor(_ color: Color, in size: CGSize) -> CGPoint {
        var bestMatch = CGPoint(x: size.width/2, y: size.height/2)
        var minDifference: CGFloat = .infinity
        
        // Sample points across the gradient to find the closest match
        let steps = 20
        for x in 0...steps {
            for y in 0...steps {
                let point = CGPoint(
                    x: CGFloat(x) * size.width / CGFloat(steps),
                    y: CGFloat(y) * size.height / CGFloat(steps))
                
                let colorAtPoint = getColorAt(
                    x: Double(point.x/size.width),
                    y: Double(point.y/size.height))
                
                let difference = colorDifference(color1: colorAtPoint, color2: color)
                if difference < minDifference {
                    minDifference = difference
                    bestMatch = point
                }
            }
        }
        return bestMatch
    }
    
    // Add this helper to compare colors
    private func colorDifference(color1: Color, color2: Color) -> CGFloat {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var (h1, s1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (h2, s2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        uiColor1.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)
        uiColor2.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)
        
        // Calculate difference in hue, saturation, and brightness
        let hueDiff = min(abs(h1 - h2), 1 - abs(h1 - h2))
        let satDiff = abs(s1 - s2)
        let brightDiff = abs(b1 - b2)
        
        return hueDiff + satDiff + brightDiff
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient layer
                LinearGradient(
                    colors: baseColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                // Vertical white gradient overlay
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.7), location: 0),
                        .init(color: .clear, location: 0.5),
                        .init(color: .black.opacity(0.7), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.softLight)
                
                // Dot pattern overlay
                GeometryReader { geo in
                    Path { path in
                        let size = 10.0
                        for x in stride(from: 0, through: geo.size.width, by: size) {
                            for y in stride(from: 0, through: geo.size.height, by: size) {
                                path.addEllipse(in: CGRect(x: x, y: y, width: 1, height: 1))
                            }
                        }
                    }
                    .fill(.white.opacity(0.15))
                    .blendMode(.plusLighter)
                }
                
                // Touch indicator
                if isDragging {
                    Circle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 30, height: 30)
                        .position(dragLocation)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragLocation = value.location
                        selectedColor = getColorAt(
                            x: value.location.x/geometry.size.width,
                            y: value.location.y/geometry.size.height
                        )
                    }
                    .onEnded { value in
                        selectedColor = getColorAt(
                            x: value.location.x/geometry.size.width,
                            y: value.location.y/geometry.size.height
                        )
                        isDragging = false
                    }
                    .exclusively(before: DragGesture())
            )
            .onChange(of: selectedColor) { _, newColor in
                isDragging = true
                dragLocation = findPositionForColor(newColor, in: geometry.size)
            }
        }
    }
    
    private func getColorAt(x: Double, y: Double) -> Color {
        let normalizedX = max(0, min(1, x))
        let normalizedY = max(0, min(1, y))
        
        let colorCount = Double(baseColors.count - 1)
        let baseIndex = Int(normalizedX * colorCount)
        let nextIndex = min(baseIndex + 1, baseColors.count - 1)
        let colorFraction = normalizedX * colorCount - Double(baseIndex)
        
        let baseColor = UIColor(baseColors[baseIndex])
        let nextColor = UIColor(baseColors[nextIndex])
        
        var (h1, s1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (h2, s2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        baseColor.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)
        nextColor.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)
        
        let h = h1 + (h2 - h1) * colorFraction
        let s = 1.0
        let b = max(0.3, 1.0 - (normalizedY * 0.7))
        
        return Color(hue: Double(h), saturation: Double(s), brightness: Double(b))
    }
}

#Preview {
    CustomColorPicker(selectedColor: .constant(.blue))
} 