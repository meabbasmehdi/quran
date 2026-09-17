import SwiftUI

public enum AppColors {
    public static let background = Color(red: 0.051, green: 0.067, blue: 0.09) // #0D1117
    public static let backgroundSecondary = Color(red: 0.102, green: 0.122, blue: 0.18) // #1A1F2E
    public static let surface = Color(red: 0.118, green: 0.141, blue: 0.2) // #1E2433
    public static let surfaceElevated = Color(red: 0.145, green: 0.169, blue: 0.231) // #252B3B
    public static let accent = Color(red: 0.788, green: 0.659, blue: 0.298) // #C9A84C
    public static let accentMuted = accent.opacity(0.6)
    public static let textPrimary = Color(red: 0.941, green: 0.929, blue: 0.902) // #F0EDE6
    public static let textSecondary = Color(red: 0.545, green: 0.541, blue: 0.522) // #8B8A85
    public static let arabicText = Color(red: 0.961, green: 0.941, blue: 0.91) // #F5F0E8
    public static let focusGlow = accent.opacity(0.3)
    public static let playingHighlight = accent.opacity(0.15)
    public static let error = Color(red: 0.878, green: 0.396, blue: 0.353) // #E0655A
    public static let divider = textSecondary.opacity(0.2)
}
