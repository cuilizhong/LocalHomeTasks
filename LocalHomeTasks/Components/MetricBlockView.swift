import SwiftUI

struct MetricBlockView: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color
    let background: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
    }
}
