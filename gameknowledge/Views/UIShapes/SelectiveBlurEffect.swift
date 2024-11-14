//
//  SelectiveBlurEffect.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/11/24.
//

import SwiftUI

struct SelectiveBlur: ViewModifier {
    let radius: CGFloat
    let regions: [CGRect]  // Regions to keep clear (not blurred)
    
    func body(content: Content) -> some View {
        content
            .overlay {
                // Base blur layer
                Rectangle()
                    .fill(.white.opacity(0.01))  // Nearly transparent to capture gestures
                    .blur(radius: radius)
                    // Cut out clear regions
                    .mask {
                        Rectangle()
                            .overlay {
                                // Clear holes for unblurred regions
                                ForEach(regions.indices, id: \.self) { index in
                                    Rectangle()
                                        .fill(.black)
                                        .frame(width: regions[index].width,
                                               height: regions[index].height)
                                        .offset(x: regions[index].minX,
                                               y: regions[index].minY)
                                        .blendMode(.destinationOut)
                                }
                            }
                    }
            }
    }
}

// Extension to make it easier to use
extension View {
    func selectiveBlur(radius: CGFloat, regions: [CGRect] = []) -> some View {
        modifier(SelectiveBlur(radius: radius, regions: regions))
    }
}




