import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(PreferencesStore.self) private var preferences
    @Environment(FocusCoordinator.self) private var focusCoordinator
    
    @FocusState private var focusTarget: FocusTarget?
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                // Progress Bar
                ProgressBar(progress: viewModel.progress)
                    .frame(width: 800)
                    .padding(.top, AppSpacing.xl)
                
                ZStack {
                    // Content Area
                    Group {
                        switch viewModel.currentStep {
                        case .welcome:
                            WelcomeStepView()
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        case .translation:
                            TranslationStepView(viewModel: viewModel, focusTarget: $focusTarget)
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        case .fontSettings:
                            FontSettingsStepView(viewModel: viewModel, focusTarget: $focusTarget)
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        case .reciter:
                            ReciterStepView(viewModel: viewModel, focusTarget: $focusTarget)
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 250)
                    .focusSection()
                    .id(viewModel.currentStep)

                    // Side actions stay reachable from every list row with one
                    // horizontal remote movement.
                    HStack {
                        VStack(spacing: AppSpacing.md) {
                            if viewModel.canGoBack {
                                Button(action: {
                                    viewModel.previousStep()
                                }) {
                                    Text("Back")
                                        .frame(minWidth: 150)
                                        .padding(.vertical, AppSpacing.md)
                                }
                                .buttonStyle(QuranButtonStyle())
                                .background(focusTarget == .onboardingBack ? AppColors.surfaceElevated : AppColors.surface)
                                .cornerRadius(AppRadius.medium)
                                .focused($focusTarget, equals: .onboardingBack)
                                .quranFocusStyle(isFocused: focusTarget == .onboardingBack, cornerRadius: AppRadius.medium)
                            }

                            Button(action: {
                                if viewModel.isLastStep {
                                    viewModel.complete(preferences: preferences)
                                } else {
                                    viewModel.nextStep()
                                }
                            }) {
                                Text(viewModel.isLastStep ? "Start Reading" : "Continue")
                                    .frame(minWidth: 180)
                                    .padding(.vertical, AppSpacing.md)
                            }
                            .buttonStyle(QuranButtonStyle())
                            .background(focusTarget == .onboardingContinue ? AppColors.accent : AppColors.accent.opacity(0.8))
                            .foregroundColor(AppColors.textPrimary)
                            .cornerRadius(AppRadius.medium)
                            .focused($focusTarget, equals: .onboardingContinue)
                            .quranFocusStyle(isFocused: focusTarget == .onboardingContinue, cornerRadius: AppRadius.medium)
                        }
                        .focusSection()

                        Spacer()

                        Button(action: {
                            viewModel.skip(preferences: preferences)
                        }) {
                            Text("Skip")
                                .frame(minWidth: 150)
                                .padding(.vertical, AppSpacing.md)
                        }
                        .buttonStyle(QuranButtonStyle())
                        .background(focusTarget == .onboardingSkip ? AppColors.surfaceElevated : AppColors.surface)
                        .cornerRadius(AppRadius.medium)
                        .focused($focusTarget, equals: .onboardingSkip)
                        .quranFocusStyle(isFocused: focusTarget == .onboardingSkip, cornerRadius: AppRadius.medium)
                        .focusSection()
                    }
                    .padding(.horizontal, 70)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.loadData()
            focusTarget = .onboardingContinue
        }
        .onChange(of: viewModel.currentStep) { _, _ in
            Task { @MainActor in
                await Task.yield()
                focusTarget = preferredContentTarget
            }
        }
        .onChange(of: focusTarget) { _, newValue in
            if let newValue {
                let zone: FocusZone = isActionTarget(newValue) ? .onboardingActions : .onboardingContent
                focusCoordinator.reportFocus(newValue, in: zone)
            }
        }
    }

    private var preferredContentTarget: FocusTarget {
        switch viewModel.currentStep {
        case .welcome:
            return .onboardingContinue
        case .translation:
            if case .content(let editions) = viewModel.translations,
               let index = editions.firstIndex(where: { $0.identifier == viewModel.selectedTranslation }) {
                return .onboardingItem(index)
            }
            return .onboardingContinue
        case .fontSettings:
            return .onboardingFontOption(viewModel.arabicFontName)
        case .reciter:
            if case .content(let editions) = viewModel.reciters,
               let index = editions.firstIndex(where: { $0.identifier == viewModel.selectedReciter }) {
                return .onboardingItem(index)
            }
            return .onboardingContinue
        }
    }

    private var currentItemCount: Int {
        switch viewModel.currentStep {
        case .translation:
            return viewModel.translations.contentValue?.count ?? 0
        case .reciter:
            return viewModel.reciters.contentValue?.count ?? 0
        default:
            return 0
        }
    }

    private func isActionTarget(_ target: FocusTarget) -> Bool {
        switch target {
        case .onboardingBack, .onboardingContinue, .onboardingSkip:
            return true
        default:
            return false
        }
    }

    private func moveFocus(_ direction: MoveCommandDirection) {
        guard let current = focusTarget else {
            focusTarget = preferredContentTarget
            return
        }

        switch current {
        case .onboardingItem(let index):
            switch direction {
            case .up where index > 0:
                focusTarget = .onboardingItem(index - 1)
            case .down where index + 1 < currentItemCount:
                focusTarget = .onboardingItem(index + 1)
            case .down where index + 1 == currentItemCount:
                focusTarget = .onboardingContinue
            case .left:
                focusTarget = .onboardingContinue
            case .right:
                focusTarget = .onboardingSkip
            default:
                break
            }

        case .onboardingFontOption(let storedValue):
            let choices = ArabicFontChoice.allCases
            let index = choices.firstIndex(where: { $0.rawValue == storedValue }) ?? 0
            switch direction {
            case .left:
                focusTarget = index > 0 ? .onboardingFontOption(choices[index - 1].rawValue) : .onboardingContinue
            case .right:
                focusTarget = index + 1 < choices.count ? .onboardingFontOption(choices[index + 1].rawValue) : .onboardingSkip
            case .down:
                focusTarget = .onboardingFontDecrease
            default:
                break
            }

        case .onboardingFontDecrease:
            switch direction {
            case .right: focusTarget = .onboardingFontIncrease
            case .up: focusTarget = .onboardingFontOption(viewModel.arabicFontName)
            case .down: focusTarget = .onboardingContinue
            case .left: focusTarget = .onboardingContinue
            default: break
            }

        case .onboardingFontIncrease:
            switch direction {
            case .left: focusTarget = .onboardingFontDecrease
            case .up: focusTarget = .onboardingFontOption(viewModel.arabicFontName)
            case .down: focusTarget = .onboardingContinue
            case .right: focusTarget = .onboardingSkip
            default: break
            }

        case .onboardingBack:
            switch direction {
            case .right: focusTarget = preferredContentTarget
            case .down: focusTarget = .onboardingContinue
            default: break
            }

        case .onboardingContinue:
            switch direction {
            case .up where viewModel.canGoBack: focusTarget = .onboardingBack
            case .right: focusTarget = preferredContentTarget
            default: break
            }

        case .onboardingSkip:
            switch direction {
            case .left: focusTarget = preferredContentTarget
            default: break
            }

        default:
            break
        }
    }
}

private struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(AppColors.surface)
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(AppColors.accent)
                    .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 6)
                    .cornerRadius(3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 6)
    }
}
