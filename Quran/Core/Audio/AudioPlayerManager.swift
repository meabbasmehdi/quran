import SwiftUI
import AVFoundation
import Combine

@Observable
@MainActor
final class AudioPlayerManager {
    // State
    private(set) var state: AudioPlayerState = .idle
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var currentAyahNumber: Int? = nil
    private(set) var currentSurahNumber: Int? = nil
    
    // Player
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var rateObservation: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?
    
    // Playback queue
    private var ayahAudioURLs: [(ayahNumber: Int, url: URL)] = []
    private var currentQueueIndex: Int = 0
    
    // MARK: - Public API
    
    /// Load ayah audio URLs for sequential playback
    func loadPlaybackQueue(ayahs: [(ayahNumber: Int, url: URL)], startingAt ayahNumber: Int? = nil) {
        stop()
        currentAyahNumber = nil
        ayahAudioURLs = ayahs
        if let start = ayahNumber,
           let index = ayahs.firstIndex(where: { $0.ayahNumber == start }) {
            currentQueueIndex = index
        } else {
            currentQueueIndex = 0
        }
    }
    
    /// Play a specific URL
    func play(url: URL) {
        stop()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            state = .failed(error.localizedDescription)
            return
        }
        
        state = .loading
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        
        setupObservers()
        player?.play()
    }
    
    /// Play the current queue item
    func playCurrentAyah() {
        guard currentQueueIndex < ayahAudioURLs.count else {
            state = .completed
            return
        }
        let entry = ayahAudioURLs[currentQueueIndex]
        currentAyahNumber = entry.ayahNumber
        play(url: entry.url)
    }
    
    /// Play a specific ayah from the queue
    func playAyah(_ ayahNumber: Int) {
        guard let index = ayahAudioURLs.firstIndex(where: { $0.ayahNumber == ayahNumber }) else { return }
        currentQueueIndex = index
        playCurrentAyah()
    }
    
    func pause() {
        player?.pause()
        state = .paused
    }
    
    func resume() {
        player?.play()
        state = .playing
    }
    
    func togglePlayPause() {
        togglePlayPause(startingAt: nil)
    }

    func togglePlayPause(startingAt ayahNumber: Int?) {
        switch state {
        case .playing: pause()
        case .paused: resume()
        case .idle, .completed, .failed:
            if let ayahNumber {
                playAyah(ayahNumber)
            } else {
                playCurrentAyah()
            }
        default: break
        }
    }
    
    func nextAyah() {
        guard currentQueueIndex + 1 < ayahAudioURLs.count else {
            state = .completed
            return
        }
        currentQueueIndex += 1
        playCurrentAyah()
    }
    
    func previousAyah() {
        // If more than 3 seconds in, restart current. Otherwise go back.
        if currentTime > 3 {
            seek(to: 0)
        } else if currentQueueIndex > 0 {
            currentQueueIndex -= 1
            playCurrentAyah()
        } else {
            seek(to: 0)
        }
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
    
    func stop() {
        player?.pause()
        removeObservers()
        player = nil
        state = .idle
        currentTime = 0
        duration = 0
    }
    
    func setSurah(_ number: Int) {
        currentSurahNumber = number
    }
    
    // MARK: - Time Formatting
    
    var currentTimeFormatted: String {
        formatTime(currentTime)
    }
    
    var durationFormatted: String {
        formatTime(duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Observers
    
    private func setupObservers() {
        // Time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        
        guard let avPlayer = player else { return }
        
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let manager = self else { return }
            let seconds = time.seconds
            Task { @MainActor [manager] in
                manager.currentTime = seconds
            }
        }
        
        // Status observation
        statusObservation = avPlayer.currentItem?.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            guard let manager = self else { return }
            let status = item.status
            let duration = item.duration.seconds
            let failureMessage = item.error?.localizedDescription ?? "Playback failed"
            let isActuallyPlaying = avPlayer.timeControlStatus == .playing
            Task { @MainActor [manager] in
                switch status {
                case .readyToPlay:
                    manager.state = isActuallyPlaying ? .playing : .buffering
                    manager.duration = duration
                case .failed:
                    manager.state = .failed(failureMessage)
                default:
                    break
                }
            }
        }

        rateObservation = avPlayer.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, _ in
            guard let manager = self else { return }
            let statusCode: Int
            switch player.timeControlStatus {
            case .playing: statusCode = 2
            case .waitingToPlayAtSpecifiedRate: statusCode = 1
            case .paused: statusCode = 0
            @unknown default: statusCode = 0
            }
            Task { @MainActor [manager] in
                switch statusCode {
                case 2:
                    manager.state = .playing
                case 1 where manager.state != .paused:
                    manager.state = .buffering
                default:
                    break
                }
            }
        }
        
        // Completion notification
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { [weak self] _ in
            guard let manager = self else { return }
            Task { @MainActor [manager] in
                manager.handlePlaybackComplete()
            }
        }
    }
    
    private func removeObservers() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        statusObservation?.invalidate()
        statusObservation = nil
        rateObservation?.invalidate()
        rateObservation = nil
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }
    
    private func handlePlaybackComplete() {
        // Auto-advance to next ayah
        if currentQueueIndex + 1 < ayahAudioURLs.count {
            nextAyah()
        } else {
            state = .completed
            currentAyahNumber = nil
        }
    }
    
}
