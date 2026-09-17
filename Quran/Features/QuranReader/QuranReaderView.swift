import SwiftUI

struct QuranReaderView: View {
  @State private var viewModel: QuranReaderViewModel
  @State private var isPlayerVisible = true
  @Environment(PreferencesStore.self) private var preferences
  @Environment(ReadingStateStore.self) private var readingStateStore
  @Environment(PlaybackStateStore.self) private var playbackStateStore
  @Environment(FocusCoordinator.self) private var focusCoordinator
  @Environment(AppRouter.self) private var router
  @Environment(AudioPlayerManager.self) private var audioPlayer
  @FocusState private var focusTarget: FocusTarget?

  init(source: ReadingSource) {
    _viewModel = State(initialValue: QuranReaderViewModel(source: source))
  }

  var body: some View {
    ZStack {
      AppColors.background.ignoresSafeArea()
      VStack(spacing: 0) {
        // Top Bar
        topBar
        // Content
        switch viewModel.viewState {
        case .idle, .loading:
          LoadingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty(let message):
          EmptyStateView(icon: "text.book.closed", message: message)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let error):
          ErrorStateView(message: error.localizedDescription) {
            Task { await viewModel.loadContent(preferences: preferences) }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .content(let ayahs):
          HStack(spacing: AppSpacing.xl) {
            readerContent(ayahs: ayahs)
            if isPlayerVisible {
              ReaderControlsBar(
                focusTarget: $focusTarget,
                onReciter: { viewModel.showQuickSettings = true },
                onClose: hidePlayer,
                focusedAyahNumber: viewModel.focusedAyahNumber
              )
              .frame(width: 330)
            }
          }
          .padding(.horizontal, AppSpacing.xl)
          .padding(.bottom, AppSpacing.lg)
        }
      }
      .disabled(viewModel.showQuickSettings)
      .accessibilityHidden(viewModel.showQuickSettings)
      if viewModel.showQuickSettings {
        QuickSettingsOverlay(focusTarget: $focusTarget) {
          viewModel.showQuickSettings = false
        }
        .zIndex(10)
      }
    }
    .task {
      await viewModel.loadContent(preferences: preferences)
      restoreReadingPosition()
      configurePlaybackQueue()
    }
    .onDisappear {
      viewModel.saveReadingState(store: readingStateStore)
      savePlaybackState()
    }
    .onChange(of: focusTarget) { _, newValue in
      guard let newValue else { return }
      switch newValue {
      case .readerAyah(let number):
        viewModel.focusedAyahNumber = number
        focusCoordinator.reportFocus(newValue, in: .readerContent)
      case .readerBack, .readerReciter, .readerPlayPause, .readerPrevious,
        .readerNext, .readerPlayerShow, .readerPlayerClose, .readerQuickSettings:
        focusCoordinator.reportFocus(newValue, in: .readerControls)
      case .readerOverlayClose, .readerOverlayFontDecrease, .readerOverlayFontIncrease,
        .readerOverlayTranslation, .readerOverlayReciter:
        focusCoordinator.reportFocus(newValue, in: .overlay)
      default:
        break
      }
    }
    .onChange(of: focusCoordinator.pendingRequest) { _, request in
      if let request, isReaderTarget(request) {
        focusTarget = request
        _ = focusCoordinator.consumePendingRequest()
      }
    }
    .onChange(of: audioPlayer.currentAyahNumber) { _, ayahNumber in
      viewModel.playingAyahNumber = ayahNumber
    }
    .onChange(of: preferences.selectedReciter) { _, _ in
      configurePlaybackQueue()
    }
  }

  private var topBar: some View {
    HStack {
      Button(action: {
        router.goBack()
      }) {
        HStack(spacing: AppSpacing.sm) {
          Image(systemName: "chevron.left")
          Text("Back")
        }
        .padding(AppSpacing.sm)
      }
      .buttonStyle(QuranButtonStyle())
      .background(focusTarget == .readerBack ? AppColors.surfaceElevated : Color.clear)
      .cornerRadius(AppRadius.medium)
      .focused($focusTarget, equals: .readerBack)
      .quranFocusStyle(isFocused: focusTarget == .readerBack, cornerRadius: AppRadius.medium)
      Spacer()
      if let surah = viewModel.surahInfo {
        Text(surah.arabicName)
          .font(AppTypography.arabicFont(size: 24, name: preferences.arabicFontName))
          .foregroundStyle(AppColors.textPrimary)
      }
      Spacer()
      HStack(spacing: AppSpacing.md) {
        if !isPlayerVisible {
          Button(action: showPlayer) {
            HStack(spacing: AppSpacing.sm) {
              Text("Show Player")
              Image(systemName: "play.rectangle.fill")
            }
            .padding(AppSpacing.sm)
          }
          .buttonStyle(QuranButtonStyle())
          .background(focusTarget == .readerPlayerShow ? AppColors.surfaceElevated : Color.clear)
          .cornerRadius(AppRadius.medium)
          .focused($focusTarget, equals: .readerPlayerShow)
          .quranFocusStyle(
            isFocused: focusTarget == .readerPlayerShow,
            cornerRadius: AppRadius.medium
          )
        }
        Button(action: {
          viewModel.showQuickSettings.toggle()
        }) {
          HStack(spacing: AppSpacing.sm) {
            Text("Quick Settings")
            Image(systemName: "gearshape.fill")
          }
          .padding(AppSpacing.sm)
        }
        .buttonStyle(QuranButtonStyle())
        .background(focusTarget == .readerQuickSettings ? AppColors.surfaceElevated : Color.clear)
        .cornerRadius(AppRadius.medium)
        .focused($focusTarget, equals: .readerQuickSettings)
        .quranFocusStyle(
          isFocused: focusTarget == .readerQuickSettings, cornerRadius: AppRadius.medium)
      }
    }
    .focusSection()
    .padding(.horizontal, AppSpacing.xl)
    .padding(.top, AppSpacing.md)
  }

  @ViewBuilder

  private func readerContent(ayahs: [Ayah]) -> some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: AppSpacing.lg) {
          // Keep the Surah intro in the scrollable content instead of
          // permanently consuming reading height. This gives large Ayahs
          // substantially more room while preserving the intro at the top.
          readerIntroSection
            .padding(.horizontal, 40)
          ForEach(ayahs, id: \.numberInSurah) { ayah in
            if case .juz = viewModel.readingSource,
              ayah.numberInSurah == 1
            {
              if ayah.surahNumber != 1, ayah.surahNumber != 9 {
                bismillahSection
                  .padding(.horizontal, 40)
              }
              surahBoundary(for: ayah)
            }
            AyahRow(
              ayah: ayah,
              displayState: viewModel.displayState(for: ayah),
              preferences: preferences,
              action: {}
            )
            .focused($focusTarget, equals: .readerAyah(ayah.numberInSurah))
            .padding(.horizontal, 40)
            .id(ayah.numberInSurah)
          }
        }
        .focusSection()
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xl)
      }
      .onAppear {
        // If we are restoring a later Ayah, bring it into view. For the
        // first Ayah, leave the compact Surah intro visible on initial load.
        if case .readerAyah(let number) = focusTarget,
          number != ayahs.first?.numberInSurah
        {
          proxy.scrollTo(number, anchor: .top)
        }
      }
      .onChange(of: audioPlayer.currentAyahNumber) { _, ayahNumber in
        guard let ayahNumber else { return }
        withAnimation(.easeInOut(duration: 0.28)) {
          // Top alignment is more robust than centering for large Ayah
          // cards because it avoids cutting both the top and bottom.
          proxy.scrollTo(ayahNumber, anchor: .top)
        }
      }
    }
  }

  @ViewBuilder

  private var readerIntroSection: some View {
    if let surah = viewModel.surahInfo {
      let isJuz: Bool = {
        if case .juz = viewModel.readingSource { return true }
        return false
      }()
      let juzNumber: Int? = {
        if case .juz(let number) = viewModel.readingSource { return number }
        return nil
      }()
      VStack(spacing: AppSpacing.sm) {
        if !isJuz, surah.number != 1, surah.number != 9 {
          bismillahSection
        }
        SurahHeaderView(
          surah: surah,
          isJuzMode: isJuz,
          juzNumber: juzNumber,
          arabicFontName: preferences.arabicFontName
        )
        // Preserve the existing SurahHeaderView implementation, but make
        // its presentation denser so it does not dominate the reader.
        .scaleEffect(0.80, anchor: .center)
        .padding(.vertical, -20)
      }
      .padding(.horizontal, AppSpacing.lg)
      .padding(.vertical, AppSpacing.md)
      .background(
        RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
          .fill(AppColors.surface.opacity(0.72))
      )
      .overlay(
        RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
          .stroke(AppColors.divider.opacity(0.65), lineWidth: 1)
      )
    }
  }

  private func surahBoundary(for ayah: Ayah) -> some View {
    VStack(spacing: AppSpacing.md) {
      Divider()
        .background(AppColors.divider)
      if let arabicName = ayah.surahName {
        Text(arabicName)
          .font(AppTypography.arabicFont(size: 40, name: preferences.arabicFontName))
          .foregroundStyle(AppColors.textPrimary)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppSpacing.lg)
  }

  private var bismillahSection: some View {
    HStack(spacing: AppSpacing.md) {
      Capsule()
        .fill(AppColors.divider.opacity(0.72))
        .frame(maxWidth: 84)
        .frame(height: 1)
      Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
        .font(AppTypography.arabicFont(size: 30, name: preferences.arabicFontName))
        .foregroundStyle(AppColors.arabicText)
        .lineLimit(1)
        .minimumScaleFactor(0.78)
        .layoutPriority(1)
      Capsule()
        .fill(AppColors.divider.opacity(0.72))
        .frame(maxWidth: 84)
        .frame(height: 1)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, AppSpacing.md)
    .padding(.vertical, AppSpacing.sm)
    .accessibilityLabel("Bismillah ir-Rahman ir-Rahim")
  }

  private func restoreReadingPosition() {
    let number: Int
    if let savedNumber = readingStateStore.lastAyahNumber,
      viewModel.ayahs.contains(where: { $0.numberInSurah == savedNumber })
    {
      number = savedNumber
    } else {
      number = viewModel.ayahs.first?.numberInSurah ?? 1
    }
    viewModel.focusedAyahNumber = number
    focusTarget = .readerAyah(number)
  }

  private func configurePlaybackQueue() {
    guard case .content(let ayahs) = viewModel.viewState else { return }
    var queue: [(ayahNumber: Int, url: URL)] = []
    let bismillahURL = Endpoint.ayahAudio(
      edition: preferences.selectedReciter,
      ayah: 1
    ).url
    for ayah in ayahs {
      if ayah.numberInSurah == 1,
        ayah.surahNumber != 1,
        ayah.surahNumber != 9
      {
        queue.append((ayahNumber: 1, url: bismillahURL))
      }
      queue.append(
        (
          ayahNumber: ayah.numberInSurah,
          url: Endpoint.ayahAudio(
            edition: preferences.selectedReciter,
            ayah: ayah.globalNumber
          ).url
        ))
    }
    if case .surah(let number) = viewModel.readingSource {
      audioPlayer.setSurah(number)
    }
    audioPlayer.loadPlaybackQueue(
      ayahs: queue,
      startingAt: viewModel.focusedAyahNumber
    )
  }

  private func savePlaybackState() {
    guard let surah = audioPlayer.currentSurahNumber,
      let ayah = audioPlayer.currentAyahNumber
    else { return }
    playbackStateStore.save(
      surah: surah,
      ayah: ayah,
      reciter: preferences.selectedReciter,
      time: audioPlayer.currentTime,
      duration: audioPlayer.duration
    )
  }

  private func hidePlayer() {
    audioPlayer.stop()
    isPlayerVisible = false
    focusTarget = .readerPlayerShow
  }

  private func showPlayer() {
    isPlayerVisible = true
    focusTarget = .readerPlayerClose
  }

  private func isReaderTarget(_ target: FocusTarget) -> Bool {
    switch target {
    case .readerBack, .readerAyah, .readerReciter, .readerPlayPause,
      .readerPrevious, .readerNext, .readerPlayerShow, .readerPlayerClose,
      .readerQuickSettings, .readerOverlayClose,
      .readerOverlayFontDecrease, .readerOverlayFontIncrease,
      .readerOverlayTranslation, .readerOverlayReciter:
      return true
    default:
      return false
    }
  }

  private func moveFocus(_ direction: MoveCommandDirection) {
    guard let current = focusTarget else {
      restoreReadingPosition()
      return
    }
    if viewModel.showQuickSettings {
      switch current {
      case .readerOverlayClose:
        if direction == .down { focusTarget = .readerOverlayFontDecrease }
      case .readerOverlayFontDecrease:
        if direction == .right { focusTarget = .readerOverlayFontIncrease }
        if direction == .up { focusTarget = .readerOverlayClose }
        if direction == .down { focusTarget = .readerOverlayTranslation }
      case .readerOverlayFontIncrease:
        if direction == .left { focusTarget = .readerOverlayFontDecrease }
        if direction == .up { focusTarget = .readerOverlayClose }
        if direction == .down { focusTarget = .readerOverlayTranslation }
      case .readerOverlayTranslation:
        if direction == .up { focusTarget = .readerOverlayFontDecrease }
        if direction == .down { focusTarget = .readerOverlayReciter }
      case .readerOverlayReciter:
        if direction == .up { focusTarget = .readerOverlayTranslation }
        if direction == .down { focusTarget = .readerOverlayClose }
      default:
        focusTarget = .readerOverlayFontDecrease
      }
      return
    }
    let currentAyahTarget = FocusTarget.readerAyah(
      viewModel.focusedAyahNumber ?? viewModel.ayahs.first?.numberInSurah ?? 1
    )
    switch current {
    case .readerAyah(let number):
      guard let index = viewModel.ayahs.firstIndex(where: { $0.numberInSurah == number }) else {
        return
      }
      switch direction {
      case .up where index > 0:
        focusTarget = .readerAyah(viewModel.ayahs[index - 1].numberInSurah)
      case .up:
        focusTarget = .readerBack
      case .down where index + 1 < viewModel.ayahs.count:
        focusTarget = .readerAyah(viewModel.ayahs[index + 1].numberInSurah)
      case .right:
        focusTarget = .readerPlayPause
      default:
        break
      }
    case .readerBack:
      if direction == .right { focusTarget = .readerQuickSettings }
      if direction == .down { focusTarget = currentAyahTarget }
    case .readerQuickSettings:
      if direction == .left { focusTarget = .readerBack }
      if direction == .down { focusTarget = .readerReciter }
    case .readerReciter:
      if direction == .left { focusTarget = currentAyahTarget }
      if direction == .up { focusTarget = .readerQuickSettings }
      if direction == .down { focusTarget = .readerPlayPause }
    case .readerPrevious:
      if direction == .left { focusTarget = currentAyahTarget }
      if direction == .right { focusTarget = .readerPlayPause }
      if direction == .up { focusTarget = .readerReciter }
    case .readerPlayPause:
      if direction == .left { focusTarget = .readerPrevious }
      if direction == .right { focusTarget = .readerNext }
      if direction == .up { focusTarget = .readerReciter }
      if direction == .down { focusTarget = currentAyahTarget }
    case .readerNext:
      if direction == .left { focusTarget = .readerPlayPause }
      if direction == .up { focusTarget = .readerReciter }
      if direction == .down || direction == .right { focusTarget = currentAyahTarget }
    default:
      break
    }
  }
}
