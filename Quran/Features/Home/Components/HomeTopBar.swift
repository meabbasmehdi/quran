import SwiftUI

struct HomeTopBar: View {
    @FocusState.Binding var focusTarget: FocusTarget?
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        HStack {
            Text("Quran")
                .font(AppTypography.title)
                .foregroundColor(AppColors.accent)
            
            Spacer()
            
            HStack(spacing: AppSpacing.md) {
                Button {
                    router.navigate(to: .settings)
                } label: {
                    Image(systemName: "gearshape")
                        .padding(AppSpacing.sm)
                        .background(focusTarget == .settings ? AppColors.surfaceElevated : Color.clear)
                        .clipShape(Circle())
                }
                .buttonStyle(QuranButtonStyle())
                .focused($focusTarget, equals: .settings)
                .quranFocusStyle(isFocused: focusTarget == .settings)
            }
        }
        .focusSection()
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.md)
    }
}
