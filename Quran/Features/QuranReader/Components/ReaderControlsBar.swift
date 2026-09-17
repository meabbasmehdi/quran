import SwiftUI

struct ReaderControlsBar: View {
    @FocusState.Binding var focusTarget: FocusTarget?
    @Environment(AudioPlayerManager.self) private var audioPlayer
    @Environment(PreferencesStore.self) private var preferences

    let onReciter: () -> Void
    let onClose: () -> Void
    let focusedAyahNumber: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack {
                Text("Playback")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(QuranButtonStyle())
                .focused($focusTarget, equals: .readerPlayerClose)
                .quranFocusStyle(
                    isFocused: focusTarget == .readerPlayerClose,
                    cornerRadius: 22
                )
                .accessibilityLabel("Close player")
            }

            playbackStatus

            Button(action: onReciter) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "person.wave.2.fill")
                        .foregroundStyle(AppColors.accent)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reciter")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Text(reciterName)
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(AppSpacing.md)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
            }
            .buttonStyle(QuranButtonStyle())
            .focused($focusTarget, equals: .readerReciter)
            .quranFocusStyle(
                isFocused: focusTarget == .readerReciter,
                cornerRadius: AppRadius.medium
            )

            HStack(spacing: AppSpacing.md) {
                ControlButton(
                    iconName: "backward.fill",
                    target: .readerPrevious,
                    focusTarget: $focusTarget,
                    action: audioPlayer.previousAyah
                )

                ControlButton(
                    iconName: audioPlayer.state.isPlaying ? "pause.fill" : "play.fill",
                    target: .readerPlayPause,
                    focusTarget: $focusTarget,
                    isPrimary: true,
                    showsLoading: audioPlayer.state == .loading || audioPlayer.state == .buffering,
                    action: {
                        audioPlayer.togglePlayPause(startingAt: focusedAyahNumber)
                    }
                )

                ControlButton(
                    iconName: "forward.fill",
                    target: .readerNext,
                    focusTarget: $focusTarget,
                    action: audioPlayer.nextAyah
                )
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ProgressView(value: playbackProgress)
                    .tint(AppColors.accent)

                HStack {
                    Text(audioPlayer.currentTimeFormatted)
                    Spacer()
                    Text(audioPlayer.durationFormatted)
                }
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .monospacedDigit()
            }

            Spacer(minLength: 0)
        }
        .focusSection()
        .padding(AppSpacing.lg)
        .background(AppColors.backgroundSecondary.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(AppColors.accent.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 16, x: 0, y: 8)
    }

    private var reciterName: String {
        preferences.selectedReciter
            .split(separator: ".")
            .last
            .map { String($0).capitalized } ?? preferences.selectedReciter
    }

    private var playbackProgress: Double {
        guard audioPlayer.duration > 0 else { return 0 }
        return min(max(audioPlayer.currentTime / audioPlayer.duration, 0), 1)
    }

    @ViewBuilder
    private var playbackStatus: some View {
        HStack(spacing: AppSpacing.sm) {
            switch audioPlayer.state {
            case .idle:
                Image(systemName: "waveform")
                Text("Ready to play")
            case .loading:
                ProgressView()
                    .tint(AppColors.accent)
                Text("Loading ayah audio…")
            case .buffering:
                ProgressView()
                    .tint(AppColors.accent)
                Text("Buffering…")
            case .playing:
                Image(systemName: "speaker.wave.2.fill")
                Text("Playing Ayah \(audioPlayer.currentAyahNumber ?? 1)")
            case .paused:
                Image(systemName: "pause.circle.fill")
                Text("Paused")
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                Text("Playback complete")
            case .failed(let message):
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(AppColors.error)
                Text(message)
                    .lineLimit(2)
            }
        }
        .font(AppTypography.caption)
        .foregroundStyle(AppColors.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 28)
    }
}

private struct ControlButton: View {
    let iconName: String
    let target: FocusTarget
    @FocusState.Binding var focusTarget: FocusTarget?
    var isPrimary = false
    var showsLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if showsLoading {
                    ProgressView()
                        .tint(AppColors.textPrimary)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: isPrimary ? 26 : 20, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
                .frame(width: isPrimary ? 74 : 62, height: isPrimary ? 74 : 62)
                .background(isPrimary ? AppColors.accent.opacity(0.28) : AppColors.surface)
                .clipShape(Circle())
        }
        .buttonStyle(QuranButtonStyle())
        .focused($focusTarget, equals: target)
        .quranFocusStyle(
            isFocused: focusTarget == target,
            cornerRadius: isPrimary ? 37 : 31
        )
    }
}
