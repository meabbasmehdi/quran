import SwiftUI

struct SettingsRow: View {
    let title: String
    let value: String
    
    @Environment(\.isFocused) private var isFocused
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(isFocused ? AppColors.textPrimary : AppColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(isFocused ? AppColors.textPrimary : AppColors.textSecondary)
            
            Image(systemName: "chevron.right")
                .foregroundStyle(isFocused ? AppColors.textPrimary : AppColors.textSecondary)
                .font(.caption)
                .padding(.leading, AppSpacing.sm)
        }
        .padding(AppSpacing.md)
        .background(Color.clear)
        .quranFocusStyle(isFocused: isFocused)
        .frame(minHeight: 80)
    }
}

