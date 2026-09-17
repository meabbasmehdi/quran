import SwiftUI

struct QuickSettingsOverlay: View {
    @Environment(PreferencesStore.self) private var preferences
    @Environment(FocusCoordinator.self) private var focusCoordinator
    @Environment(AppRouter.self) private var router
    @FocusState.Binding var focusTarget: FocusTarget?
    
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Dark transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            
            // Settings Panel
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    HStack {
                        Text("Reader Settings")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Button("Close") {
                            close()
                        }
                        .buttonStyle(QuranButtonStyle())
                        .focused($focusTarget, equals: .readerOverlayClose)
                        .quranFocusStyle(
                            isFocused: focusTarget == .readerOverlayClose,
                            cornerRadius: AppRadius.medium
                        )
                    }
                    .padding(.bottom, AppSpacing.sm)
                    
                    // Font Size
                    HStack {
                        Text("Font Size")
                            .font(AppTypography.body)
                        Spacer()
                        HStack(spacing: AppSpacing.lg) {
                            Button {
                                if preferences.fontSize > 22 {
                                    preferences.fontSize -= 4
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .frame(width: 52, height: 52)
                            }
                            .buttonStyle(QuranButtonStyle())
                            .focused($focusTarget, equals: .readerOverlayFontDecrease)
                            .quranFocusStyle(
                                isFocused: focusTarget == .readerOverlayFontDecrease,
                                cornerRadius: 26
                            )
                            
                            Text("\(Int(preferences.fontSize))")
                                .font(AppTypography.body)
                                .frame(width: 60, alignment: .center)
                            
                            Button {
                                if preferences.fontSize < 50 {
                                    preferences.fontSize += 4
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .frame(width: 52, height: 52)
                            }
                            .buttonStyle(QuranButtonStyle())
                            .focused($focusTarget, equals: .readerOverlayFontIncrease)
                            .quranFocusStyle(
                                isFocused: focusTarget == .readerOverlayFontIncrease,
                                cornerRadius: 26
                            )
                        }
                    }
                    .padding(.vertical, AppSpacing.sm)
                    
                    Divider()
                        .background(AppColors.surfaceElevated)
                    
                    // Translation shortcut
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Translation")
                                .font(AppTypography.body)
                            Text(preferences.selectedTranslation)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        // This assumes there is a .settings route or similar in AppRouter
                        Button("Change") {
                            close()
                            router.navigate(to: .settings)
                        }
                        .buttonStyle(QuranButtonStyle())
                        .focused($focusTarget, equals: .readerOverlayTranslation)
                        .quranFocusStyle(
                            isFocused: focusTarget == .readerOverlayTranslation,
                            cornerRadius: AppRadius.medium
                        )
                    }
                    .padding(.vertical, AppSpacing.sm)
                    
                    // Reciter shortcut
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Reciter")
                                .font(AppTypography.body)
                            Text(preferences.selectedReciter)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Button("Change") {
                            close()
                            router.navigate(to: .settings)
                        }
                        .buttonStyle(QuranButtonStyle())
                        .focused($focusTarget, equals: .readerOverlayReciter)
                        .quranFocusStyle(
                            isFocused: focusTarget == .readerOverlayReciter,
                            cornerRadius: AppRadius.medium
                        )
                    }
                    .padding(.vertical, AppSpacing.sm)
                }
                .padding(AppSpacing.xl)
            }
            .frame(width: 600)
            .focusSection()
            .shadow(radius: 20)
        }
        .onExitCommand {
            close()
        }
        .onAppear {
            focusCoordinator.pushOverlayFocus(initialTarget: .readerOverlayFontDecrease)
            focusTarget = .readerOverlayFontDecrease
        }
        .onDisappear {
            focusCoordinator.popOverlayFocus()
        }
    }
    
    private func close() {
        onClose()
    }
}
