import SwiftUI

/// Search screen for finding Quran content
struct SearchView: View {
    @Environment(AppRouter.self) private var router
    @Environment(PreferencesStore.self) private var preferences
    @Environment(FocusCoordinator.self) private var focusCoordinator
    
    @State private var viewModel = SearchViewModel()
    @FocusState private var focusTarget: FocusTarget?
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                searchHeader
                
                // Content
                searchContent
            }
        }
        .onAppear {
            viewModel.searchEdition = preferences.selectedTranslation
            focusTarget = .searchField
        }
        .onChange(of: focusTarget) { _, newValue in
            if let newValue {
                focusCoordinator.reportFocus(newValue, in: .search)
            }
        }
    }
    
    // MARK: - Header
    
    private var searchHeader: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(AppColors.accent)
                
                Text("Search the Quran")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.xxl)
            .focusSection()
            .padding(.top, AppSpacing.lg)
            
            // Search field
            HStack(spacing: AppSpacing.md) {
                TextField("Enter a word or phrase...", text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .tint(AppColors.accent)
                    .focused($focusTarget, equals: .searchField)
                    .onSubmit {
                        viewModel.performSearch()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                    .focusEffectDisabled()
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.medium)
                            .stroke(focusTarget == .searchField ? AppColors.accent : Color.clear, lineWidth: 2)
                    )
                
                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .focused($focusTarget, equals: .searchClear)
                    .quranFocusable(cornerRadius: 24)
                }
            }
            .padding(.horizontal, AppSpacing.xxl)
            
            // Subtle divider
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1)
                .padding(.top, AppSpacing.sm)
        }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var searchContent: some View {
        switch viewModel.searchState {
        case .idle:
            searchIdleView
            
        case .loading:
            Spacer()
            LoadingView()
            Spacer()
            
        case .content(let results):
            searchResultsList(results)
            
        case .empty(let message):
            Spacer()
            EmptyStateView(icon: "text.magnifyingglass", message: message)
            Spacer()
            
        case .error(let error):
            Spacer()
            ErrorStateView(
                message: error.localizedDescription,
                onRetry: { viewModel.performSearch() }
            )
            Spacer()
        }
    }
    
    private var searchIdleView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            
            Text("Search by word or phrase")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            
            Text("Results will appear from your selected translation")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary.opacity(0.7))
            
            Spacer()
        }
    }
    
    // MARK: - Results List
    
    private func searchResultsList(_ results: [Ayah]) -> some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.xs) {
                ForEach(Array(results.enumerated()), id: \.element.id) { index, ayah in
                    Button {
                        // Navigate to reader at this surah
                        focusCoordinator.storeFocus(forScreen: .search)
                        router.navigateToReader(source: .surah(ayah.surahNumber))
                    } label: {
                        SearchResultRow(ayah: ayah)
                    }
                    .buttonStyle(QuranButtonStyle())
                    .focused($focusTarget, equals: .searchResult(index))
                    .quranFocusStyle(isFocused: focusTarget == .searchResult(index))
                }
            }
            .focusSection()
            .padding(.horizontal, AppSpacing.xxl)
            .padding(.vertical, AppSpacing.md)
        }
    }

    private var resultCount: Int {
        viewModel.searchState.contentValue?.count ?? 0
    }

    private func moveFocus(_ direction: MoveCommandDirection) {
        guard let current = focusTarget else {
            focusTarget = .searchField
            return
        }

        switch current {
        case .searchField:
            if direction == .right, !viewModel.query.isEmpty { focusTarget = .searchClear }
            if direction == .down, resultCount > 0 { focusTarget = .searchResult(0) }
        case .searchClear:
            if direction == .left { focusTarget = .searchField }
            if direction == .down, resultCount > 0 { focusTarget = .searchResult(0) }
        case .searchResult(let index):
            if direction == .up {
                focusTarget = index > 0 ? .searchResult(index - 1) : .searchField
            }
            if direction == .down, index + 1 < resultCount {
                focusTarget = .searchResult(index + 1)
            }
        default:
            break
        }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let ayah: Ayah
    @Environment(PreferencesStore.self) private var preferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Surah info
            HStack {
                if let surahName = ayah.surahEnglishName {
                    Text(surahName)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.accent)
                }
                
                Text("Ayah \(ayah.numberInSurah)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                
                Spacer()
                
                Text("Surah \(ayah.surahNumber)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            // Arabic text
            if !ayah.arabicText.isEmpty {
                Text(ayah.arabicText)
                    .font(AppTypography.arabicFont(size: 26, name: preferences.arabicFontName))
                    .foregroundStyle(AppColors.arabicText)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .environment(\.layoutDirection, .rightToLeft)
            }
            
            // Translation text
            if let translation = ayah.translationText {
                Text(translation)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
    }
}
