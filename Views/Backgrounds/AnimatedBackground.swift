import SwiftUI

struct AnimatedBackground: View {
    let backgroundColor: Color
    @State private var phase = 0.0
    
    private struct BlobPoint {
        let x: Double
        let y: Double
    }
    
    private func calculateBlobPoints(timeNow: Double, index: Int, size: CGSize) -> [BlobPoint] {
        let rotation = timeNow.remainder(dividingBy: 10) + Double(index) * 2
        let points = 8
        var pos = [BlobPoint]()
        
        for j in 0...points {
            let angle = (Double(j) * .pi * 2 / Double(points)) + rotation
            let radius = size.width/4 + sin(angle * 2 + timeNow) * 20
            pos.append(BlobPoint(
                x: size.width/2 + cos(angle) * radius,
                y: size.height/2 + sin(angle) * radius
            ))
        }
        
        return pos
    }
    
    private func drawBlob(_ context: GraphicsContext, size: CGSize, timeNow: Double, index: Int) -> Path {
        var path = Path()
        let points = calculateBlobPoints(timeNow: timeNow, index: index, size: size)
        
        if let firstPoint = points.first {
            path.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
            for point in points.dropFirst() {
                path.addLine(to: CGPoint(x: point.x, y: point.y))
            }
        }
        path.closeSubpath()
        return path
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeNow = timeline.date.timeIntervalSinceReferenceDate
                let angle = timeNow.remainder(dividingBy: 2)
                let scale = CGFloat(1 + sin(angle) * 0.2)
                
                let transform = CGAffineTransform.identity
                    .translatedBy(x: size.width/2, y: size.height/2)
                    .scaledBy(x: scale, y: scale)
                    .translatedBy(x: -size.width/2, y: -size.height/2)
                
                context.transform = transform
                
                for i in 0..<3 {
                    let blob = drawBlob(context, size: size, timeNow: timeNow, index: i)
                    context.addFilter(.blur(radius: 50))
                    context.fill(blob, with: .color(backgroundColor.opacity(0.1)))
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        AnimatedBackground(backgroundColor: .white)
    }
} 