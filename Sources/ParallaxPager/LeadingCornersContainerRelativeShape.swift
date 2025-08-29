import SwiftUI

public struct LeadingCornersContainerRelativeShape: Shape {
    var leadingCornerRadius: CGFloat = 32
    
    func path(in rect: CGRect) -> Path {
        // Get the path from ContainerRelativeShape for the environment's rounding
        let containerPath = ContainerRelativeShape().path(in: rect)
        
        // Create a rectangle that covers the trailing half, but has sharp corners
        let trailingRect = CGRect(x: rect.midX, y: rect.minY, width: rect.width / 2, height: rect.height)
        let trailingPath = Path { p in
            p.addRect(trailingRect)
        }
        
        // Create a rectangle that covers the leading half, but only uses the container shape's path
        let leadingRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width / 2, height: rect.height)
        let leadingPath = containerPath.intersection(Path(leadingRect))
        
        // Merge the leadingPath (rounded corners) with the trailingPath (rectangle)
        var finalPath = leadingPath
        finalPath.addPath(trailingPath)
        return finalPath
    }
}
