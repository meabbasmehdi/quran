import SwiftUI

/// A neutral app-wide button style that prevents tvOS from drawing its native
/// white focus plate. Focus appearance is supplied by `QuranFocusModifier`.
public struct QuranButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .focusEffectDisabled()
    }
}

public struct QuranFocusModifier: ViewModifier {
    let isFocused: Bool
    let cornerRadius: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .focusEffectDisabled()
            .background(isFocused ? AppColors.surfaceElevated : Color.clear)
            .scaleEffect(1.0)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFocused ? AppColors.accent : Color.clear, lineWidth: isFocused ? 2 : 0)
            )
            .shadow(color: isFocused ? AppColors.focusGlow : Color.clear, radius: isFocused ? 12 : 0)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

private struct QuranAutomaticFocusModifier: ViewModifier {
    @Environment(\.isFocused) private var isFocused

    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .buttonStyle(QuranButtonStyle())
            .modifier(QuranFocusModifier(isFocused: isFocused, cornerRadius: cornerRadius))
    }
}

public extension View {
    func quranFocusStyle(isFocused: Bool, cornerRadius: CGFloat = AppRadius.card) -> some View {
        self.modifier(QuranFocusModifier(isFocused: isFocused, cornerRadius: cornerRadius))
    }

    func quranFocusable(cornerRadius: CGFloat = AppRadius.card) -> some View {
        self.modifier(QuranAutomaticFocusModifier(cornerRadius: cornerRadius))
    }
    
    func quranCardStyle() -> some View {
        self
            .background(AppColors.surface)
            .cornerRadius(AppRadius.card)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
