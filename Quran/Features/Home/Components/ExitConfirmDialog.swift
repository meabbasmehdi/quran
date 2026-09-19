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
            // Dimmed backdrop. Tapping outside acts as Cancel.
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Exit App")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Are you sure you want to exit the app?")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: AppSpacing.md) {
                        Button("Cancel") {
                            onCancel()
                        }
                        .frame(width: 200, height: 56)
                        .buttonStyle(QuranButtonStyle())
                        .focused($focusTarget, equals: .exitCancel)
                        .quranFocusStyle(
                            isFocused: focusTarget == .exitCancel,
                            cornerRadius: AppRadius.medium
                        )

                        Button("Exit") {
                            onConfirm()
                        }
                        .frame(width: 200, height: 56)
                        .buttonStyle(QuranButtonStyle())
                        .focused($focusTarget, equals: .exitConfirm)
                        .quranFocusStyle(
                            isFocused: focusTarget == .exitConfirm,
                            cornerRadius: AppRadius.medium
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(AppSpacing.xl)
            }
            .frame(width: 600)
            .focusSection()
            .shadow(radius: 20)
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
}
