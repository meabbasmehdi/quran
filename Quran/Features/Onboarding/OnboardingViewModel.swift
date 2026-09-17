import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case translation = 1
    case fontSettings = 2
    case reciter = 3
}

@Observable
@MainActor
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    
    // Data
    var translations: ViewState<[Edition]> = .idle
    var reciters: ViewState<[Edition]> = .idle
    
    // Selections (synced to preferences on completion)
    var selectedTranslation: String = "en.sahih"
    var selectedReciter: String = "ar.alafasy"
    var arabicFontName: String = ""
    var fontSize: Double = 36.0
    
    private let editionRepository = EditionRepository()
    
    var canGoBack: Bool { currentStep.rawValue > 0 }
    var isLastStep: Bool { currentStep == .reciter }
    var progress: Double { Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count) }
    
    func loadData() async {
        // Load translations
        translations = .loading
        do {
            let editions = try await editionRepository.fetchTranslationEditions()
            translations = editions.isEmpty ? .empty("No translations available") : .content(editions)
        } catch let error as QuranError {
            translations = .error(error)
        } catch {
            translations = .error(.unknown)
        }
        
        // Load reciters
        reciters = .loading
        do {
            let editions = try await editionRepository.fetchReciters()
            reciters = editions.isEmpty ? .empty("No reciters available") : .content(editions)
        } catch let error as QuranError {
            reciters = .error(error)
        } catch {
            reciters = .error(.unknown)
        }
    }
    
    func nextStep() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = next
        }
    }
    
    func previousStep() {
        guard let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = prev
        }
    }
    
    func complete(preferences: PreferencesStore) {
        preferences.selectedTranslation = selectedTranslation
        preferences.selectedReciter = selectedReciter
        preferences.arabicFontName = arabicFontName
        preferences.fontSize = fontSize
        preferences.hasCompletedOnboarding = true
    }
    
    func skip(preferences: PreferencesStore) {
        // Use defaults
        preferences.hasCompletedOnboarding = true
    }
}
