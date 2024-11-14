import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct testSelectiveBlur: View {
    @State private var blurredUIImage: UIImage?

    var body: some View {
        VStack {
            if let image = blurredUIImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Loading image...")
            }
        }
        .onAppear {
            applyBlurEffectToAssetImage()
        }
    }

    // Helper function to convert CIImage to UIImage
    func convertCIImageToUIImage(_ ciImage: CIImage) -> UIImage? {
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    // Apply blur effect to the image from xcassets
    func applyBlurEffectToAssetImage() {
        guard let inputImage = UIImage(named: "400k 1"),
              let ciInputImage = CIImage(image: inputImage) else {
            print("Image not found in assets.")
            return
        }

        // Apply your blur function
        let blurredCIImage = blurImage(ciInputImage)
        
        // Convert the blurred CIImage to UIImage
        if let blurredUIImage = convertCIImageToUIImage(blurredCIImage) {
            self.blurredUIImage = blurredUIImage
        }
    }

    // Your blur function
    func blurImage(_ input: CIImage) -> CIImage {
        let filter = CIFilter.maskedVariableBlur()
        filter.inputImage = input
        
        let mask = CIFilter.smoothLinearGradient()
        mask.color0 = CIColor.white
        mask.color1 = CIColor.black
        mask.point0 = CGPoint(x: 0, y: 0)
        mask.point1 = CGPoint(x: 0, y: input.extent.height)
        
        filter.mask = mask.outputImage
        filter.radius = 25
        
        return filter.outputImage!
    }
    
    
}

#Preview {
    testSelectiveBlur()
}
