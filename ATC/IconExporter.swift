import SwiftUI
import UIKit

struct IconSize: Identifiable {
    let id: String
    let size: CGFloat
    let scale: Int
    let filename: String
    
    var scaledSize: CGFloat {
        size * CGFloat(scale)
    }
    
    init(size: CGFloat, scale: Int, filename: String) {
        self.id = "\(size)x\(size)@\(scale)x"
        self.size = size
        self.scale = scale
        self.filename = filename
    }
}

@MainActor
class IconExporter: ObservableObject {
    @Published var isExporting = false
    @Published var exportMessage = ""
    
    static let shared = IconExporter()
    
    private init() {}
    
    static let sizes: [IconSize] = [
        IconSize(size: 20, scale: 2, filename: "icon_40"),
        IconSize(size: 20, scale: 3, filename: "icon_60"),
        IconSize(size: 29, scale: 2, filename: "icon_58"),
        IconSize(size: 29, scale: 3, filename: "icon_87"),
        IconSize(size: 38, scale: 2, filename: "icon_76"),
        IconSize(size: 38, scale: 3, filename: "icon_114"),
        IconSize(size: 40, scale: 2, filename: "icon_80"),
        IconSize(size: 40, scale: 3, filename: "icon_120"),
        IconSize(size: 60, scale: 2, filename: "icon_120"),
        IconSize(size: 60, scale: 3, filename: "icon_180"),
        IconSize(size: 64, scale: 2, filename: "icon_128"),
        IconSize(size: 64, scale: 3, filename: "icon_192"),
        IconSize(size: 68, scale: 2, filename: "icon_136"),
        IconSize(size: 76, scale: 2, filename: "icon_152"),
        IconSize(size: 83.5, scale: 2, filename: "icon_167"),
        IconSize(size: 1024, scale: 1, filename: "icon_1024")
    ]
    
    func exportIcons() {
        guard !isExporting else { return }
        isExporting = true
        exportMessage = "Starting export..."
        
        Task {
            do {
                // Use absolute path to project
                let projectPath = "/Users/justinjones/Library/CloudStorage/OneDrive-ATPCO/Desktop/ATC"
                let appIconURL = URL(fileURLWithPath: projectPath)
                    .appendingPathComponent("ATC/Assets.xcassets/AppIcon.appiconset")
                
                print("Saving icons to: \(appIconURL.path)")
                
                // Create directory if needed
                try FileManager.default.createDirectory(at: appIconURL, withIntermediateDirectories: true)
                
                // Generate icons
                for size in Self.sizes {
                    let renderer = ImageRenderer(content: AppIcon(size: size.scaledSize))
                    renderer.scale = 1.0
                    
                    if let uiImage = renderer.uiImage {
                        let fileURL = appIconURL.appendingPathComponent("\(size.filename).png")
                        if let data = uiImage.pngData() {
                            try data.write(to: fileURL)
                            await MainActor.run {
                                exportMessage = "Saved \(size.filename).png"
                            }
                        }
                    }
                }
                
                // Create Contents.json
                let contents = """
                {
                  "images" : [
                    {
                      "filename" : "icon_40.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "20x20"
                    },
                    {
                      "filename" : "icon_60.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "3x",
                      "size" : "20x20"
                    },
                    {
                      "filename" : "icon_58.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "29x29"
                    },
                    {
                      "filename" : "icon_87.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "3x",
                      "size" : "29x29"
                    },
                    {
                      "filename" : "icon_76.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "38x38"
                    },
                    {
                      "filename" : "icon_114.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "3x",
                      "size" : "38x38"
                    },
                    {
                      "filename" : "icon_80.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "40x40"
                    },
                    {
                      "filename" : "icon_120.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "3x",
                      "size" : "40x40"
                    },
                    {
                      "filename" : "icon_120.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "60x60"
                    },
                    {
                      "filename" : "icon_180.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "3x",
                      "size" : "60x60"
                    },
                    {
                      "filename" : "icon_128.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "64x64"
                    },
                    {
                      "filename" : "icon_192.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "3x",
                      "size" : "64x64"
                    },
                    {
                      "filename" : "icon_136.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "68x68"
                    },
                    {
                      "filename" : "icon_152.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "76x76"
                    },
                    {
                      "filename" : "icon_167.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "scale" : "2x",
                      "size" : "83.5x83.5"
                    },
                    {
                      "filename" : "icon_1024.png",
                      "idiom" : "universal",
                      "platform" : "ios",
                      "size" : "1024x1024"
                    }
                  ],
                  "info" : {
                    "author" : "xcode",
                    "version" : 1
                  }
                }
                """
                
                try contents.write(to: appIconURL.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
                
                await MainActor.run {
                    exportMessage = "Icons exported! Just clean build (⇧⌘K) and run again (⌘R)"
                    isExporting = false
                }
                
            } catch {
                await MainActor.run {
                    exportMessage = "Error: \(error.localizedDescription)"
                    isExporting = false
                }
            }
        }
    }
}

struct IconExporterPreview: View {
    @StateObject private var exporter = IconExporter.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Icon Export Preview")
                .font(.headline)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100), spacing: 20)
                ], spacing: 20) {
                    ForEach(IconExporter.sizes) { size in
                        VStack {
                            AppIcon(size: size.scaledSize)
                                .clipShape(RoundedRectangle(cornerRadius: size.scaledSize * 0.2236))
                            Text(size.id)
                                .font(.caption)
                        }
                    }
                }
                .padding()
            }
            
            if !exporter.exportMessage.isEmpty {
                Text(exporter.exportMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                exporter.exportIcons()
            }) {
                if exporter.isExporting {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("Export Icons")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(exporter.isExporting)
            .padding()
            
            Button("Done") {
                dismiss()
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    IconExporterPreview()
} 