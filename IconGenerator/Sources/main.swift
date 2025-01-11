// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import AppKit

func generateIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    let context = NSGraphicsContext.current!.cgContext
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    context.interpolationQuality = .high
    
    // Draw background gradient
    let gradient = NSGradient(colors: [
        NSColor(red: 0.102, green: 0.31, blue: 1.0, alpha: 1.0),
        NSColor(red: 0.039, green: 0.169, blue: 0.6, alpha: 1.0)
    ])!
    gradient.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: -45)
    
    // Draw radar rings
    let scales: [CGFloat] = [0.65, 0.82, 1.0]
    for scale in scales {
        let ringPath = NSBezierPath(ovalIn: NSRect(
            x: size * (1.0 - scale) / 2.0,
            y: size * (1.0 - scale) / 2.0,
            width: size * scale,
            height: size * scale
        ))
        ringPath.lineWidth = size/128.0
        NSColor.white.withAlphaComponent(0.3).setStroke()
        ringPath.stroke()
    }
    
    // Draw radio waves
    for i in 0..<3 {
        let waveScale: CGFloat = 0.75 + CGFloat(i) * 0.15
        let waveSize = size * waveScale
        
        // Top right wave (prominent)
        let topRightPath = NSBezierPath()
        topRightPath.appendArc(
            withCenter: NSPoint(x: size/2.0, y: size/2.0),
            radius: waveSize/2.0,
            startAngle: -45,  // Positioned in top right
            endAngle: 15
        )
        topRightPath.lineWidth = size/100.0
        NSColor.white.withAlphaComponent(0.8).setStroke()
        topRightPath.stroke()
        
        // Bottom left wave (prominent)
        let bottomLeftPath = NSBezierPath()
        bottomLeftPath.appendArc(
            withCenter: NSPoint(x: size/2.0, y: size/2.0),
            radius: waveSize/2.0,
            startAngle: 135,  // Positioned in bottom left
            endAngle: 195
        )
        bottomLeftPath.lineWidth = size/100.0
        NSColor.white.withAlphaComponent(0.8).setStroke()
        bottomLeftPath.stroke()
    }
    
    // Draw center point
    let centerPoint = NSBezierPath(ovalIn: NSRect(
        x: size/2.0 - size/60.0,
        y: size/2.0 - size/60.0,
        width: size/30.0,
        height: size/30.0
    ))
    NSColor.white.withAlphaComponent(0.6).setFill()
    centerPoint.fill()
    
    // Draw airplane
    if let airplane = NSImage(systemSymbolName: "airplane", accessibilityDescription: nil) {
        let airplaneSize = size * 0.6  // Made larger
        let airplaneRect = NSRect(
            x: (size - airplaneSize) / 2.0,
            y: (size - airplaneSize) / 2.0,
            width: airplaneSize,
            height: airplaneSize
        )
        
        context.saveGState()
        
        // Move to center, rotate, move back
        context.translateBy(x: size/2.0, y: size/2.0)
        context.rotate(by: 45.0 * .pi / 180.0)  // Point to top right
        context.translateBy(x: -size/2.0, y: -size/2.0)
        
        // Set up for high quality drawing
        NSGraphicsContext.current?.imageInterpolation = .high
        NSGraphicsContext.current?.shouldAntialias = true
        
        // Draw white airplane
        NSColor.white.setFill()
        NSColor.white.setStroke()
        
        airplane.isTemplate = true
        airplane.draw(in: airplaneRect,
                     from: NSRect(origin: .zero, size: airplane.size),
                     operation: .sourceOver,
                     fraction: 1.0)
        
        // Draw again with additive blending for extra whiteness
        context.setBlendMode(.plusLighter)
        airplane.draw(in: airplaneRect,
                     from: NSRect(origin: .zero, size: airplane.size),
                     operation: .sourceOver,
                     fraction: 0.5)
        
        context.restoreGState()
    }
    
    image.unlockFocus()
    
    // Create a bitmap representation with exact dimensions
    let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size),
        pixelsHigh: Int(size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    
    bitmapRep.size = NSSize(width: size, height: size)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
    NSGraphicsContext.current?.imageInterpolation = .high
    
    image.draw(in: NSRect(origin: .zero, size: NSSize(width: size, height: size)),
               from: .zero,
               operation: .copy,
               fraction: 1.0)
    
    NSGraphicsContext.restoreGraphicsState()
    
    let finalImage = NSImage(size: NSSize(width: size, height: size))
    finalImage.addRepresentation(bitmapRep)
    
    return finalImage
}

// Base URL for icon assets
let baseURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .deletingLastPathComponent()
    .appendingPathComponent("ATC")
    .appendingPathComponent("Assets.xcassets")
    .appendingPathComponent("AppIcon.appiconset")

do {
    // Remove existing directory if it exists
    if FileManager.default.fileExists(atPath: baseURL.path) {
        try FileManager.default.removeItem(at: baseURL)
    }
    
    // Create fresh directory
    try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    
    // Generate only the required iOS app icons
    let requiredSizes = [
        (40, "40"),    // iPhone Notification 2x
        (60, "60"),    // iPhone Notification 3x
        (58, "58"),    // iPhone Settings 2x
        (87, "87"),    // iPhone Settings 3x
        (80, "80"),    // iPhone Spotlight 2x
        (120, "120"),  // iPhone Spotlight 3x and App 2x
        (180, "180"),  // iPhone App 3x
        (1024, "1024") // App Store
    ]
    
    for (size, name) in requiredSizes {
        let image = generateIcon(size: CGFloat(size))
        
        // Create bitmap representation
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            continue
        }
        
        // Configure bitmap properties
        bitmapRep.size = NSSize(width: size, height: size)
        
        // Generate PNG data
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            continue
        }
        
        // Save PNG file
        let url = baseURL.appendingPathComponent("icon_\(name).png")
        try pngData.write(to: url)
        print("Generated icon_\(name).png (\(size)x\(size))")
    }
    
    // Generate Contents.json
    let contents = """
    {
      "images" : [
        {
          "filename" : "icon_40.png",
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "20x20"
        },
        {
          "filename" : "icon_60.png",
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "20x20"
        },
        {
          "filename" : "icon_58.png",
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "29x29"
        },
        {
          "filename" : "icon_87.png",
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "29x29"
        },
        {
          "filename" : "icon_80.png",
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "40x40"
        },
        {
          "filename" : "icon_120.png",
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "40x40"
        },
        {
          "filename" : "icon_120.png",
          "idiom" : "iphone",
          "scale" : "2x",
          "size" : "60x60"
        },
        {
          "filename" : "icon_180.png",
          "idiom" : "iphone",
          "scale" : "3x",
          "size" : "60x60"
        },
        {
          "filename" : "icon_1024.png",
          "idiom" : "ios-marketing",
          "scale" : "1x",
          "size" : "1024x1024"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    let contentsURL = baseURL.appendingPathComponent("Contents.json")
    try contents.write(to: contentsURL, atomically: true, encoding: .utf8)
    print("Generated Contents.json")
    
} catch {
    print("Error generating icons: \(error)")
}
