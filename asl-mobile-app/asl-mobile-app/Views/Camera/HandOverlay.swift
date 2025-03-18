import SwiftUI
import MediaPipeTasksVision

/// A straight line.
struct Line {
    let from: CGPoint
    let to: CGPoint
}

/// This structure holds the display parameters for the overlay to be drawn on a hand landmarker object.
struct HandOverlay {
    let dots: [CGPoint]
    let lines: [Line]
}

/// SwiftUI view to visualize the hand landmarks overlay.
struct HandOverlayView: View {
    var handOverlays: [HandOverlay] = []
    var imageSize: CGSize = .zero
    var edgeOffset: CGFloat = 0.0
    var imageContentMode: ContentMode = .fit
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let adjustedOverlays = transformOverlays(for: size)
                
                for overlay in adjustedOverlays {
                    for line in overlay.lines {
                        var path = Path()
                        path.move(to: line.from)
                        path.addLine(to: line.to)
                        context.stroke(path, with: .color(.blue), lineWidth: 2)
                    }
                    
                    for dot in overlay.dots {
                        let rect = CGRect(x: dot.x - 2.5, y: dot.y - 2.5, width: 5, height: 5)
                        context.fill(Ellipse().path(in: rect), with: .color(.red))
                    }
                }
            }
        }
    }
    
    /// Transforms overlay points to match SwiftUI coordinate system
    private func transformOverlays(for viewSize: CGSize) -> [HandOverlay] {
        print("Image Size: \(imageSize)")
        let scaleFactor = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let xOffset = (viewSize.width - imageSize.width * scaleFactor) / 2
        let yOffset = (viewSize.height - imageSize.height * scaleFactor) / 2
        
        return handOverlays.map { overlay in
            let dots = overlay.dots.map { CGPoint(x: $0.x * scaleFactor + xOffset, y: $0.y * scaleFactor + yOffset) }
            let lines = overlay.lines.map { Line(from: CGPoint(x: $0.from.x * scaleFactor + xOffset, y: $0.from.y * scaleFactor + yOffset),
                                                 to: CGPoint(x: $0.to.x * scaleFactor + xOffset, y: $0.to.y * scaleFactor + yOffset)) }
            return HandOverlay(dots: dots, lines: lines)
        }
    }
}

struct HandOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        HandOverlayView(handOverlays: [
            HandOverlay(dots: [CGPoint(x: 50, y: 50), CGPoint(x: 100, y: 100)],
                        lines: [Line(from: CGPoint(x: 50, y: 50), to: CGPoint(x: 100, y: 100))])
        ], imageSize: CGSize(width: 200, height: 200))
    }
}
