import SwiftUI

public struct LoadingView: View {
    public init() {}
    
    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct EmptyStateView: View {
    let icon: String
    let message: String
    
    public init(icon: String = "text.page", message: String) {
        self.icon = icon
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(AppColors.textSecondary)
            
            Text(message)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    public init(message: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }
    
    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(AppColors.error)
            
            Text(message)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Retry", action: onRetry)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.accent)
                .foregroundColor(AppColors.background)
                .cornerRadius(AppRadius.medium)
                .quranFocusable(cornerRadius: AppRadius.medium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
