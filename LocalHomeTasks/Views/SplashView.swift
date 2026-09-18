import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("BrandMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104, height: 104)
                    .accessibilityHidden(true)

                VStack(spacing: 6) {
                    Text("LocalHomeTasks")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColor.textPrimary)

                    Text("Home maintenance, kept on track")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .padding(AppSpacing.screen)
        }
    }
}

#Preview {
    SplashView()
}
