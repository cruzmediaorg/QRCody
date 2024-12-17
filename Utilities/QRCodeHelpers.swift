import SwiftUI
import QRCode

struct QRCodeHelpers {
    static func pixelShape(for style: QRPixelStyle) -> QRCodePixelShapeGenerator {
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
    
    static func eyeShapeGenerator(for shape: QREyeShape) -> QRCodeEyeShapeGenerator {
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
} 
