import SwiftUI

/// Spacing tokens (4pt grid) + platform density from the design system's
/// `tokens/spacing.css` / `platform.css`. macOS tightens for pointer.
enum DSSpacing {
    static let s0: CGFloat = 0
    static let s0_5: CGFloat = 2
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20
    static let s6: CGFloat = 24
    static let s7: CGFloat = 32
    static let s8: CGFloat = 40

    // Semantic (platform-aware)
    #if os(macOS)
    static let screenMargin: CGFloat = 20
    static let sectionGap: CGFloat = 24
    static let rowPadY: CGFloat = 6
    static let rowPadX: CGFloat = 12
    static let cardPad: CGFloat = 14
    static let hitTarget: CGFloat = 28
    static let rowMinHeight: CGFloat = 28
    #else
    static let screenMargin: CGFloat = 16
    static let sectionGap: CGFloat = 32
    static let rowPadY: CGFloat = 12
    static let rowPadX: CGFloat = 16
    static let cardPad: CGFloat = 16
    static let hitTarget: CGFloat = 44
    static let rowMinHeight: CGFloat = 44
    #endif

    static let stackGap: CGFloat = 12
    static let rowGap: CGFloat = 8
    static let gutter: CGFloat = 12
}

/// Continuous ("squircle") corner radii from `tokens/radius.css`.
enum DSRadius {
    static let xs: CGFloat = 6     // checkboxes, small chips
    static let sm: CGFloat = 8     // buttons, text fields
    static let md: CGFloat = 10    // list rows
    static let lg: CGFloat = 12    // cards, grouped lists
    static let xl: CGFloat = 16    // popovers
    static let xxl: CGFloat = 20   // sheets, modals
    static let capsule: CGFloat = 999
}

/// Shadow tokens from `tokens/elevation.css` (dark values; the system softens
/// under light appearance). Quiet by default; depth reads from surface lightness.
struct DSShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let card = DSShadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
    static let raised = DSShadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 4)
    static let popover = DSShadow(color: .black.opacity(0.55), radius: 14, x: 0, y: 8)
    static let sheet = DSShadow(color: .black.opacity(0.55), radius: 20, x: 0, y: -2)
}

extension View {
    func dsShadow(_ shadow: DSShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
