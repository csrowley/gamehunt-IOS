//
//  ImageModifers.swift
//  gameknowledge
//
//  Created by Chris Rowley on 11/14/24.
//

import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageModifers {
//    func selectiveBlur(from uiImage: UIImage, radius: Float) -> UIImage? {
//        guard let ciImage = CIImage(image: uiImage) else { return nil }
//        
//        let h = ciImage.extent.size.height
//        
//        // Create top gradient - this creates a solid blur above the focus area
//        let topGradient = CIFilter.linearGradient()
//        topGradient.point0 = CGPoint(x: 0, y: 0.7 * h)  // Start of clear area
//        topGradient.color0 = CIColor(red: 0, green: 1, blue: 0, alpha: 1)  // Fully blurred
//        topGradient.point1 = CGPoint(x: 0, y: 0.65 * h)  // Transition to clear
//        topGradient.color1 = CIColor(red: 0, green: 1, blue: 0, alpha: 0)  // Clear area
//        
//        // Create bottom gradient - this creates a solid blur below the focus area
//        let bottomGradient = CIFilter.linearGradient()
//        bottomGradient.point0 = CGPoint(x: 0, y: 0.45 * h)  // Start of blur
//        bottomGradient.color0 = CIColor(red: 0, green: 1, blue: 0, alpha: 1)  // Fully blurred
//        bottomGradient.point1 = CGPoint(x: 0, y: 0.5 * h)   // Transition to clear
//        bottomGradient.color1 = CIColor(red: 0, green: 1, blue: 0, alpha: 0)  // Clear area
//        
//        // Combine gradients
//        let gradientMask = CIFilter.additionCompositing()
//        gradientMask.inputImage = topGradient.outputImage
//        gradientMask.backgroundImage = bottomGradient.outputImage
//        
//        // Create blur effect
//        let blur = CIFilter.gaussianBlur()
//        blur.inputImage = ciImage
//        blur.radius = radius
//        
//        // Blend the original and blurred image using the mask
//        let blend = CIFilter.blendWithMask()
//        blend.inputImage = blur.outputImage  // Blurred image
//        blend.backgroundImage = ciImage      // Original image
//        blend.maskImage = gradientMask.outputImage
//        
//        guard let outputImage = blend.outputImage,
//              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent)
//        else { return nil }
//        
//        return UIImage(cgImage: cgImage)
//    }
}
