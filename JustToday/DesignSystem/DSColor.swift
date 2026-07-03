import SwiftUI

/// Semantic color tokens for Just Today. Backed by asset-catalog Color Sets
/// (Assets.xcassets/Colors), which resolve light/dark automatically per the
/// system appearance. Values come from the design system's `tokens/colors.css`.
enum DSColor {
    // Surfaces (elevation ladder)
    static let bgBase = Color("bg-base")
    static let surface = Color("surface")
    static let surfaceElevated = Color("surface-elevated")
    static let surfaceOverlay = Color("surface-overlay")

    // Text (label roles)
    static let textPrimary = Color("text-primary")
    static let textSecondary = Color("text-secondary")
    static let textTertiary = Color("text-tertiary")
    static let textQuaternary = Color("text-quaternary")
    static let onAccent = Color("on-accent")

    // Accent / Must Do (brand)
    static let accent = Color("accent")
    static let accentPressed = Color("accent-pressed")
    static let accentText = Color("accent-text")

    // Bonus
    static let bonus = Color("bonus")
    static let bonusPressed = Color("bonus-pressed")
    static let bonusText = Color("bonus-text")

    // Success / Done
    static let done = Color("done")
    static let donePressed = Color("done-pressed")
    static let doneText = Color("done-text")

    // Destructive
    static let destructive = Color("destructive")
    static let destructivePressed = Color("destructive-pressed")
    static let destructiveText = Color("destructive-text")

    // Lines & fills
    static let separator = Color("separator")
    static let separatorOpaque = Color("separator-opaque")
    static let border = Color("border")
    static let fillPrimary = Color("fill-primary")
    static let fillSecondary = Color("fill-secondary")
    static let fillTertiary = Color("fill-tertiary")
    static let fillQuaternary = Color("fill-quaternary")

    // Tints (wash / selected) = base color at 16%
    static let accentTint = accent.opacity(0.16)
    static let bonusTint = bonus.opacity(0.16)
    static let doneTint = done.opacity(0.16)
    static let destructiveTint = destructive.opacity(0.16)
}

extension TaskCategory {
    /// The DS category accent color (Must Do amber, Bonus blue).
    var dsColor: Color { self == .mustDo ? DSColor.accent : DSColor.bonus }
    var dsTint: Color { self == .mustDo ? DSColor.accentTint : DSColor.bonusTint }
}
