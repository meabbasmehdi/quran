import SwiftUI

public struct AyahTextView: View {
    let arabicText: String
    let fontSize: CGFloat
    let fontName: String
    
    public init(arabicText: String, fontSize: CGFloat = 36, fontName: String = "") {
        self.arabicText = arabicText
        self.fontSize = fontSize
        self.fontName = fontName
    }
    
    public var body: some View {
        Text(arabicText)
            .font(AppTypography.arabicFont(size: fontSize, name: fontName))
            .foregroundColor(AppColors.arabicText)
            .lineSpacing(16)
            .multilineTextAlignment(.trailing)
            .environment(\.layoutDirection, .rightToLeft)
            .fixedSize(horizontal: false, vertical: true)
    }
}
