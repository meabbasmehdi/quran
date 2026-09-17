import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("About")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Quran for tvOS")
                            .font(AppTypography.headline)
                        
                        Text("Version 1.0")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Divider()
                            .background(AppColors.surfaceElevated)
                        
                        Text("Data Sources")
                            .font(AppTypography.bodyMedium)
                            .padding(.top, AppSpacing.sm)
                        
                        Text("• Quran text and translations: Al Quran Cloud API (alquran.cloud)")
                            .font(AppTypography.body)
                        
                        Text("• Audio recitations: Islamic Network CDN")
                            .font(AppTypography.body)
                        
                        Text("This app uses open-source Quran data. All content rights belong to respective copyright holders.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.top, AppSpacing.md)
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .padding(AppSpacing.xl)
        }
    }
}

