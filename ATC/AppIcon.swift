import SwiftUI

struct AppIcon: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "1a4fff"), Color(hex: "0a2b99")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Radar rings - made more visible
            ForEach([0.65, 0.82, 1.0], id: \.self) { scale in
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: size/128)
                    .frame(width: size * scale)
            }
            
            // Radio waves - bottom right
            ForEach(0..<3) { index in
                Circle()
                    .trim(from: 0.2, to: 0.35)
                    .stroke(
                        .white.opacity(0.8),
                        style: StrokeStyle(lineWidth: size/100, lineCap: .round)
                    )
                    .frame(width: size * (0.75 + Double(index) * 0.15))
                    .rotationEffect(.degrees(15.0 + Double(index) * 5))
            }
            
            // Radio waves - top left, more visible
            ForEach(0..<3) { index in
                Circle()
                    .trim(from: 0.7, to: 0.85)
                    .stroke(
                        .white.opacity(0.8),
                        style: StrokeStyle(lineWidth: size/100, lineCap: .round)
                    )
                    .frame(width: size * (0.75 + Double(index) * 0.15))
                    .rotationEffect(.degrees(15.0 + Double(index) * 5))
            }
            
            // Center point
            Circle()
                .fill(.white.opacity(0.6))
                .frame(width: size/30, height: size/30)
            
            // Airplane symbol - centered and much larger
            Image(systemName: "airplane")
                .font(.system(size: size/3.0, weight: .bold))  // Adjusted size
                .foregroundStyle(.white)
                .rotationEffect(.degrees(-45))
                .shadow(color: .black.opacity(0.5), radius: size/32, x: size/64, y: size/64)
        }
        .frame(width: size, height: size)
        .background(Color(hex: "1a4fff"))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 