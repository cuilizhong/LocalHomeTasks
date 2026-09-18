import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(AppColor.primary)

            Text(title)
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Label(actionTitle, systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSpacing.buttonHeight)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColor.primary)
            .padding(.top, 4)
        }
        .padding(AppSpacing.screen)
        .frame(maxWidth: .infinity)
        .background(AppColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
    }
}
