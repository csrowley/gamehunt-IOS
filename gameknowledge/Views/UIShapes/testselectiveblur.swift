import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// Selective Blur View Modifier
struct SelectiveBlurModifier: ViewModifier {
    let radius: Float
    let imageName: String
    
    func body(content: Content) -> some View {
        if let uiImage = applySelectiveBlur(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            content  // Show original content if image fails to load
        }
    }
    
    // Function to apply the selective blur
    private func applySelectiveBlur(named imageName: String) -> UIImage? {
        guard let uiImage = UIImage(named: imageName),
              let ciImage = CIImage(image: uiImage) else {
            return nil  // Return nil if loading fails
        }
        
        let h = ciImage.extent.size.height
        
        // Create top gradient
        let topGradient = CIFilter.linearGradient()
        topGradient.point0 = CGPoint(x: 0, y: 0.7 * h)
        topGradient.color0 = CIColor(red: 0, green: 1, blue: 0, alpha: 1)
        topGradient.point1 = CGPoint(x: 0, y: 0.65 * h)
        topGradient.color1 = CIColor(red: 0, green: 1, blue: 0, alpha: 0)
        
        // Create bottom gradient
        let bottomGradient = CIFilter.linearGradient()
        bottomGradient.point0 = CGPoint(x: 0, y: 0.45 * h)
        bottomGradient.color0 = CIColor(red: 0, green: 1, blue: 0, alpha: 1)
        bottomGradient.point1 = CGPoint(x: 0, y: 0.5 * h)
        bottomGradient.color1 = CIColor(red: 0, green: 1, blue: 0, alpha: 0)
        
        // Combine gradients
        let gradientMask = CIFilter.additionCompositing()
        gradientMask.inputImage = topGradient.outputImage
        gradientMask.backgroundImage = bottomGradient.outputImage
        
        // Create blur effect
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = ciImage
        blur.radius = radius
        
        // Blend original and blurred image using mask
        let blend = CIFilter.blendWithMask()
        blend.inputImage = blur.outputImage
        blend.backgroundImage = ciImage
        blend.maskImage = gradientMask.outputImage
        
        guard let outputImage = blend.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent)
        else { return uiImage }
        
        return UIImage(cgImage: cgImage)
    }
}

// Extend View to easily apply the modifier
extension View {
    func selectiveBlur(imageName: String, radius: Float) -> some View {
        self.modifier(SelectiveBlurModifier(radius: radius, imageName: imageName))
    }
}

// Test View
struct TestSelectiveBlur: View {
    var body: some View {
        Image("400k 1")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .selectiveBlur(imageName: "400k 1", radius: 3)  // Apply the selective blur modifier
    }
}

#Preview {
    TestSelectiveBlur()
}
