import SwiftUI

/// Typography tokens (San Francisco). Sizes/line-heights follow the design
/// system's `tokens/typography.css`, with macOS density from `platform.css`
/// (iOS 17pt body, macOS 13pt). Rounded design carries the wordmark + numerals.
struct DSTextStyle {
    let size: CGFloat
    let lineHeight: CGFloat
    let weight: Font.Weight
    let tracking: CGFloat
    var design: Font.Design = .default

    var font: Font { .system(size: size, weight: weight, design: design) }
}

enum DSFont {
    #if os(macOS)
    static let largeTitle  = DSTextStyle(size: 26, lineHeight: 32, weight: .bold,     tracking: 0.37, design: .rounded)
    static let title1      = DSTextStyle(size: 22, lineHeight: 26, weight: .regular,  tracking: 0.36)
    static let title2      = DSTextStyle(size: 17, lineHeight: 22, weight: .semibold, tracking: 0.35)   // section headers
    static let title3      = DSTextStyle(size: 15, lineHeight: 20, weight: .regular,  tracking: 0.38)
    static let headline    = DSTextStyle(size: 13, lineHeight: 16, weight: .semibold, tracking: -0.08)  // task title
    static let body        = DSTextStyle(size: 13, lineHeight: 16, weight: .regular,  tracking: -0.08)
    static let callout     = DSTextStyle(size: 12, lineHeight: 15, weight: .regular,  tracking: -0.31)
    static let subheadline = DSTextStyle(size: 11, lineHeight: 14, weight: .regular,  tracking: -0.23)
    static let footnote    = DSTextStyle(size: 10, lineHeight: 13, weight: .regular,  tracking: -0.08)
    #else
    static let largeTitle  = DSTextStyle(size: 34, lineHeight: 41, weight: .bold,     tracking: 0.37, design: .rounded)
    static let title1      = DSTextStyle(size: 28, lineHeight: 34, weight: .regular,  tracking: 0.36)
    static let title2      = DSTextStyle(size: 22, lineHeight: 28, weight: .semibold, tracking: 0.35)
    static let title3      = DSTextStyle(size: 20, lineHeight: 25, weight: .regular,  tracking: 0.38)
    static let headline    = DSTextStyle(size: 17, lineHeight: 22, weight: .semibold, tracking: -0.43)
    static let body        = DSTextStyle(size: 17, lineHeight: 22, weight: .regular,  tracking: -0.43)
    static let callout     = DSTextStyle(size: 16, lineHeight: 21, weight: .regular,  tracking: -0.31)
    static let subheadline = DSTextStyle(size: 15, lineHeight: 20, weight: .regular,  tracking: -0.23)
    static let footnote    = DSTextStyle(size: 13, lineHeight: 18, weight: .regular,  tracking: -0.08)
    #endif

    // Not overridden per platform
    static let caption1 = DSTextStyle(size: 12, lineHeight: 16, weight: .regular, tracking: 0, design: .rounded)   // counts
    static let caption2 = DSTextStyle(size: 11, lineHeight: 13, weight: .regular, tracking: 0.06)
}

extension View {
    /// Apply a DS text style (font + tracking + line spacing).
    func dsText(_ style: DSTextStyle) -> some View {
        self.font(style.font)
            .tracking(style.tracking)
            .lineSpacing(max(0, style.lineHeight - style.size))
    }
}
