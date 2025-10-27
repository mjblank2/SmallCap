import SwiftUI

// Presented modally to explain the value of notifications.
struct NotificationPrimerView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(.brandAccent)

            Text("Stay Ahead of the Market")
                .font(StyleGuide.Typography.sectionTitle)

            Text("Enable notifications to receive instant alerts when new micro-cap ideas are published.")
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Button("Enable Notifications") {
                PushNotificationHandler.shared.requestSystemPermission()
                Haptics.notifySuccess()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.brandAccent)
            .padding(.top, 20)

            Button("Maybe Later") {
                Haptics.impactLight()
                dismiss()
            }
        }
        .padding(30)
        .background(Color.backgroundCard)
        .cornerRadius(20)
        .padding()
    }
}
