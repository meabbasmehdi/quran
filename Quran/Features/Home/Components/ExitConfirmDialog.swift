import SwiftUI

/// Modal confirmation shown when the user presses Menu/Back from the root screen,
/// asking whether to exit the app. "Cancel" is focused by default for safety.
struct ExitConfirmDialog: View {
    @Environment(FocusCoordinator.self) private var focusCoordinator
    @FocusState.Binding var focusTarget: FocusTarget?

    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            // Elegant dimming — dark enough to focus attention, not so dark it hides the app.
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 0) {
                Text("Exit App")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text("Are you sure you want to exit the app?")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, AppSpacing.sm)

                HStack(spacing: AppSpacing.md) {
                    dialogButton(title: "Cancel", target: .exitCancel, action: onCancel)
                    dialogButton(title: "Exit", target: .exitConfirm, action: onConfirm)
                }
                .padding(.top, AppSpacing.lg)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.xl)
            .frame(width: 540)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColors.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.45), radius: 28, x: 0, y: 12)
            .focusSection()
        }
        .onExitCommand {
            onCancel()
        }
        .onAppear {
            focusCoordinator.pushOverlayFocus(initialTarget: .exitCancel)
            focusTarget = .exitCancel
        }
        .onDisappear {
            focusCoordinator.popOverlayFocus()
        }
    }

    /// Shared button style so both actions have identical size, padding,
    /// corner radius, typography, and alignment. Gold accent appears only on focus.
    @ViewBuilder
    private func dialogButton(
        title: String,
        target: FocusTarget,
        action: @escaping () -> Void
    ) -> some View {
        let isFocused = focusTarget == target
        Button(title, action: action)
            .font(AppTypography.bodyMedium)
            .foregroundColor(AppColors.textPrimary)
            .frame(width: 200, height: 56)
            .background(AppColors.surface)
            .cornerRadius(AppRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
            .buttonStyle(QuranButtonStyle())
            .focused($focusTarget, equals: target)
            .quranFocusStyle(isFocused: isFocused, cornerRadius: AppRadius.medium)
            .scaleEffect(isFocused ? 1.04 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: isFocused)
    }
}
