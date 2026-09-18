import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(FocusCoordinator.self) private var focusCoordinator
    @Environment(AppRouter.self) private var router
    @Environment(ReadingStateStore.self) private var readingState
    @Environment(PlaybackStateStore.self) private var playbackState
    @FocusState private var focusTarget: FocusTarget?
    
    var body: some View {
        VStack(spacing: 0) {
            HomeTopBar(focusTarget: $focusTarget)
            
            HStack(spacing: AppSpacing.md) {
                Button("Surah") {
                    viewModel.selectedTab = .surah
                }
                .buttonStyle(QuranButtonStyle())
                .focused($focusTarget, equals: .homeTab(.surah))
                .padding(AppSpacing.sm)
                .background(viewModel.selectedTab == .surah ? AppColors.surface : Color.clear)
                .quranFocusStyle(isFocused: focusTarget == .homeTab(.surah))
                
                Button("Juz") {
                    viewModel.selectedTab = .juz
                }
                .buttonStyle(QuranButtonStyle())
                .focused($focusTarget, equals: .homeTab(.juz))
                .padding(AppSpacing.sm)
                .background(viewModel.selectedTab == .juz ? AppColors.surface : Color.clear)
                .quranFocusStyle(isFocused: focusTarget == .homeTab(.juz))
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .focusSection()
            
            Group {
                switch viewModel.surahListState {
                case .idle, .loading:
                    Color.clear
                case .error(let error):
                    homeErrorState(error)
                case .empty(let message):
                    EmptyStateView(message: message)
                case .content(let surahs):
                    HStack(spacing: AppSpacing.xxl) {
                        Group {
                            if viewModel.selectedTab == .surah {
                                SurahListView(surahs: surahs, selectedSurahIndex: $viewModel.selectedSurahIndex, focusTarget: $focusTarget)
                            } else {
                                JuzListView(selectedJuzIndex: $viewModel.selectedJuzIndex, focusTarget: $focusTarget)
                            }
                        }
                        .frame(width: 1920 * 0.6)

                        ContinuePanel(
                            selectedSurah: viewModel.selectedSurah,
                            selectedJuz: viewModel.selectedJuzIndex,
                            activeTab: viewModel.selectedTab,
                            focusTarget: $focusTarget
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, AppSpacing.xl)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppColors.background.ignoresSafeArea())
        .overlay {
            switch viewModel.surahListState {
            case .idle, .loading:
                LoadingView()
                    .allowsHitTesting(false)
            default:
                EmptyView()
            }
        }
        .task {
            await viewModel.loadSurahs()
            await Task.yield()
            if focusTarget == nil {
                if isShowingError {
                    focusTarget = .homeRetry
                } else {
                    focusCoordinator.restoreFocus(forScreen: .home)
                    if focusCoordinator.pendingRequest == nil {
                        focusTarget = .surah(1)
                    }
                }
            }
        }
        .onDisappear {
            focusCoordinator.storeFocus(forScreen: .home)
        }
        .onChange(of: focusTarget) { _, newValue in
            if let newFocus = newValue {
                focusCoordinator.reportFocus(newFocus, in: focusZone(for: newFocus))
            }
        }
        .onChange(of: focusCoordinator.pendingRequest) { _, request in
            if let target = request {
                focusTarget = target
                _ = focusCoordinator.consumePendingRequest()
            }
        }
    }

    private var selectedListTarget: FocusTarget {
        switch viewModel.selectedTab {
        case .surah:
            return .surah(viewModel.selectedSurahIndex ?? 1)
        case .juz:
            return .juz(viewModel.selectedJuzIndex ?? 1)
        }
    }

    private var preferredContinueTarget: FocusTarget? {
        if readingState.hasReadingState { return .continueReading }
        if playbackState.hasPlaybackState { return .continueListening }
        return nil
    }

    private func focusZone(for target: FocusTarget) -> FocusZone {
        switch target {
        case .settings: return .homeTopActions
        case .homeTab: return .homeNavigation
        case .homeRetry: return .homeContentList
        case .surah, .juz: return .homeContentList
        case .continueReading, .continueListening: return .homeContinue
        default: return .homeContentList
        }
    }

    private func moveFocus(_ direction: MoveCommandDirection) {
        guard let current = focusTarget else {
            focusTarget = selectedListTarget
            return
        }

        switch current {
        case .settings:
            if direction == .down { focusTarget = .homeTab(.juz) }
        case .homeTab(.surah):
            if direction == .right { focusTarget = .homeTab(.juz) }
            if direction == .up { focusTarget = .settings }
            if direction == .down {
                focusTarget = isShowingError ? .homeRetry : .surah(viewModel.selectedSurahIndex ?? 1)
            }
        case .homeTab(.juz):
            if direction == .left { focusTarget = .homeTab(.surah) }
            if direction == .up { focusTarget = .settings }
            if direction == .down {
                focusTarget = isShowingError ? .homeRetry : .juz(viewModel.selectedJuzIndex ?? 1)
            }
        case .homeRetry:
            if direction == .up { focusTarget = .homeTab(viewModel.selectedTab) }
        case .surah(let number):
            if direction == .up {
                focusTarget = number > 1 ? .surah(number - 1) : .homeTab(.surah)
            }
            if direction == .down, number < 114 { focusTarget = .surah(number + 1) }
            if direction == .right, let preferredContinueTarget { focusTarget = preferredContinueTarget }
        case .juz(let number):
            if direction == .up {
                focusTarget = number > 1 ? .juz(number - 1) : .homeTab(.juz)
            }
            if direction == .down, number < 30 { focusTarget = .juz(number + 1) }
            if direction == .right, let preferredContinueTarget { focusTarget = preferredContinueTarget }
        case .continueReading:
            if direction == .left { focusTarget = selectedListTarget }
            if direction == .down, playbackState.hasPlaybackState { focusTarget = .continueListening }
        case .continueListening:
            if direction == .left { focusTarget = selectedListTarget }
            if direction == .up, readingState.hasReadingState { focusTarget = .continueReading }
        default:
            break
        }
    }

    private var isShowingError: Bool {
        if case .error = viewModel.surahListState { return true }
        return false
    }

    private func homeErrorState(_ error: QuranError) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(AppColors.error)

            Text(error.localizedDescription)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)

            Button("Retry") {
                focusTarget = .homeTab(viewModel.selectedTab)
                Task {
                    await viewModel.loadSurahs()
                    await Task.yield()
                    focusTarget = isShowingError ? .homeRetry : selectedListTarget
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.accent)
            .foregroundColor(AppColors.background)
            .cornerRadius(AppRadius.medium)
            .buttonStyle(QuranButtonStyle())
            .focused($focusTarget, equals: .homeRetry)
            .quranFocusStyle(isFocused: focusTarget == .homeRetry, cornerRadius: AppRadius.medium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .focusSection()
    }
}
