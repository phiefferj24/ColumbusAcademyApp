//
//  TodayHeaderView.swift
//  CA
//
//  Created by Jim Phieffer on 8/13/22.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct TodayHeaderView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @AppStorage("app.user.quickpin", store: UserDefaults(suiteName: "group.com.jimphieffer.CA")) var quickpin: String?
    
    fileprivate func generateQRCode(_ string: String) -> Image {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return Image(uiImage: UIImage(cgImage: cgImage)).interpolation(.none)
            }
        }
        return Image(systemName: "xmark")
    }
    
    @Binding var letterDay: String?
    let formatter = DateFormatter("EEEE, MMMM d")

    var body: some View {
        HStack {
            if let quickpin = quickpin, quickpin.count == 4, Int(quickpin) != nil {
                generateQRCode(quickpin)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding(5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 5)
                            .padding(5)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.width * 0.4)
            }
            VStack(alignment: .leading) {
                Text(letterDay ?? "...")
                    .font(.system(size: 60))
                    .fontWeight(.heavy)
                Text(formatter.string(from: Date()))
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
            }
            Spacer()
        }.padding(10)
    }
}
