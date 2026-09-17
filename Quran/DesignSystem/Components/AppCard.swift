import SwiftUI

public struct AppCard<Content: View>: View {
    let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding()
            .background(AppColors.surfaceElevated)
            .cornerRadius(AppRadius.card)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
