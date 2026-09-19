import SwiftUI

struct SettingsView: View {
    @Environment(PreferencesStore.self) private var preferences
    @Environment(FocusCoordinator.self) private var focusCoordinator
    
    @State private var viewModel = SettingsViewModel()
    @FocusState private var focusTarget: FocusTarget?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Settings")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.bottom, AppSpacing.lg)
                
                VStack(spacing: AppSpacing.sm) {
                    NavigationLink(destination: TranslationPickerView(viewModel: viewModel)) {
                        SettingsRow(
                            title: "Translation",
                            value: viewModel.translationName(for: preferences.selectedTranslation)
                        )
                    }
                    .buttonStyle(QuranButtonStyle())
                    .focused($focusTarget, equals: .settingsTranslation)
                    
                    NavigationLink(destination: ReciterPickerView(viewModel: viewModel)) {
                        SettingsRow(
                            title: "Reciter",
                            value: viewModel.reciterName(for: preferences.selectedReciter)
                        )
                    }
                    .buttonStyle(QuranButtonStyle())
                    .focused($focusTarget, equals: .settingsReciter)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Arabic Font")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)

                        HStack(spacing: AppSpacing.md) {
                            ForEach(ArabicFontChoice.allCases) { choice in
                                Button {
                                    preferences.arabicFontName = choice.rawValue
                                } label: {
                                    VStack(spacing: AppSpacing.xs) {
                                        Text("بِسْمِ اللَّهِ")
                                            .font(AppTypography.arabicFont(size: 24, name: choice.rawValue))
                                        Text(choice.title)
                                            .font(AppTypography.caption)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 72)
                                }
                                .buttonStyle(QuranButtonStyle())
                                .background(selectedFontChoice == choice ? AppColors.accent.opacity(0.2) : AppColors.surfaceElevated)
                                .cornerRadius(AppRadius.medium)
                                .focused($focusTarget, equals: .settingsFontOption(choice.rawValue))
                                .quranFocusStyle(
                                    isFocused: focusTarget == .settingsFontOption(choice.rawValue),
                                    cornerRadius: AppRadius.medium
                                )
                            }
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                    
                    // Font Size Row
                    HStack {
                        Text("Font Size")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: AppSpacing.md) {
                            Button {
                                if preferences.fontSize > 22 {
                                    preferences.fontSize -= 4
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .frame(width: 56, height: 56)
                            }
                            .buttonStyle(QuranButtonStyle())
                            .focused($focusTarget, equals: .settingsFontSizeDecrease)
                            .quranFocusStyle(
                                isFocused: focusTarget == .settingsFontSizeDecrease,
                                cornerRadius: 28
                            )
                            
                            Text("\(Int(preferences.fontSize))")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(width: 50, alignment: .center)
                            
                            Button {
                                if preferences.fontSize < 50 {
                                    preferences.fontSize += 4
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .frame(width: 56, height: 56)
                            }
                            .buttonStyle(QuranButtonStyle())
                            .focused($focusTarget, equals: .settingsFontSizeIncrease)
                            .quranFocusStyle(
                                isFocused: focusTarget == .settingsFontSizeIncrease,
                                cornerRadius: 28
                            )
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                }
                .focusSection()
            }
            .padding(AppSpacing.xl)
        }
        .task {
            await viewModel.loadEditions()
        }
        .onChange(of: focusTarget) { _, newValue in
            if let target = newValue {
                focusCoordinator.reportFocus(target, in: .settingsList)
            }
        }
        .onChange(of: focusCoordinator.pendingRequest) { _, newValue in
            if let request = newValue, isSettingsTarget(request) {
                focusTarget = request
                _ = focusCoordinator.consumePendingRequest()
            }
        }
        .onAppear {
            if focusTarget == nil {
                focusTarget = .settingsTranslation
            }
        }
    }

    private var selectedFontTarget: FocusTarget {
        .settingsFontOption(selectedFontChoice.rawValue)
    }

    private var selectedFontChoice: ArabicFontChoice {
        ArabicFontChoice.storedValue(preferences.arabicFontName)
    }

    private func isSettingsTarget(_ target: FocusTarget) -> Bool {
        switch target {
        case .settingsTranslation, .settingsReciter, .settingsFont,
             .settingsFontOption, .settingsFontSize, .settingsFontSizeDecrease,
             .settingsFontSizeIncrease:
            return true
        default:
            return false
        }
    }

    private func moveFocus(_ direction: MoveCommandDirection) {
        guard let current = focusTarget else {
            focusTarget = .settingsTranslation
            return
        }

        switch current {
        case .settingsTranslation:
            if direction == .down { focusTarget = .settingsReciter }
        case .settingsReciter:
            if direction == .up { focusTarget = .settingsTranslation }
            if direction == .down { focusTarget = selectedFontTarget }
        case .settingsFontOption(let storedValue):
            let choices = ArabicFontChoice.allCases
            let index = choices.firstIndex(where: { $0.rawValue == storedValue }) ?? 0
            switch direction {
            case .left where index > 0:
                focusTarget = .settingsFontOption(choices[index - 1].rawValue)
            case .right where index + 1 < choices.count:
                focusTarget = .settingsFontOption(choices[index + 1].rawValue)
            case .up:
                focusTarget = .settingsReciter
            case .down:
                focusTarget = .settingsFontSizeDecrease
            default:
                break
            }
        case .settingsFontSizeDecrease:
            switch direction {
            case .right: focusTarget = .settingsFontSizeIncrease
            case .up: focusTarget = selectedFontTarget
            default: break
            }
        case .settingsFontSizeIncrease:
            switch direction {
            case .left: focusTarget = .settingsFontSizeDecrease
            case .up: focusTarget = selectedFontTarget
            default: break
            }
        default:
            break
        }
    }
}
