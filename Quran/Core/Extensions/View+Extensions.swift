import SwiftUI

extension View {
    /// Applies the standard Quran focus style to a view
    func quranFocusEffect(isFocused: Bool) -> some View {
        self.modifier(QuranFocusModifier(isFocused: isFocused, cornerRadius: AppRadius.card))
    }
    
    /// Convenience modifier for background with safe area ignore
    func appBackground() -> some View {
        self.background(AppColors.background.ignoresSafeArea())
    }
}
