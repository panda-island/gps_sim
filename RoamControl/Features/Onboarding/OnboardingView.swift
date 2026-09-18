import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPage = 0

    let isReplay: Bool
    private let pages = OnboardingPage.pages

    init(isReplay: Bool = false) {
        self.isReplay = isReplay
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.16),
                    Color.cyan.opacity(0.07),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Text("ROAM CONTROL")
                        .font(.caption.weight(.bold))
                        .tracking(2.2)
                        .foregroundStyle(.secondary)

                    if isReplay {
                        HStack {
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("關閉介紹")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 22) {
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == selectedPage ? Color.blue : Color.secondary.opacity(0.25))
                                .frame(width: index == selectedPage ? 24 : 8, height: 8)
                                .animation(
                                    reduceMotion ? nil : .spring(response: 0.3),
                                    value: selectedPage
                                )
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("第 \(selectedPage + 1) 頁，共 \(pages.count) 頁")

                    Button {
                        advance()
                    } label: {
                        HStack {
                            Text(finalButtonTitle)
                            Image(systemName: finalButtonSymbol)
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
    }

    private var isLastPage: Bool {
        selectedPage == pages.count - 1
    }

    private func advance() {
        if isLastPage {
            if isReplay {
                dismiss()
            } else {
                appModel.completeOnboarding()
            }
        } else {
            if reduceMotion {
                selectedPage += 1
            } else {
                withAnimation {
                    selectedPage += 1
                }
            }
        }
    }

    private var finalButtonTitle: String {
        if !isLastPage { return "繼續" }
        return isReplay ? "完成" : "設定此 iPhone"
    }

    private var finalButtonSymbol: String {
        if !isLastPage { return "arrow.right" }
        return isReplay ? "checkmark" : "iphone.and.arrow.forward"
    }
}

private struct OnboardingPageView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let page: OnboardingPage

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    Spacer(minLength: 20)

                    Image(systemName: page.symbol)
                        .font(.system(
                            size: dynamicTypeSize.isAccessibilitySize ? 46 : 64,
                            weight: .semibold
                        ))
                        .foregroundStyle(.white)
                        .frame(
                            width: dynamicTypeSize.isAccessibilitySize ? 96 : 132,
                            height: dynamicTypeSize.isAccessibilitySize ? 96 : 132
                        )
                        .background(
                            LinearGradient(
                                colors: page.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(
                                cornerRadius: dynamicTypeSize.isAccessibilitySize ? 26 : 34,
                                style: .continuous
                            )
                        )
                        .shadow(color: page.colors[0].opacity(0.28), radius: 24, y: 14)
                        .accessibilityHidden(true)

                    VStack(spacing: 14) {
                        Text(page.title)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(page.message)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 28)

                    if page.showsUsageStatisticsControl {
                        usageStatisticsCard
                            .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var usageStatisticsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(
                "分享匿名使用統計",
                isOn: Binding(
                    get: { appModel.sharesAnonymousUsageStatistics },
                    set: appModel.setSharesAnonymousUsageStatistics
                )
            )
            .font(.headline)

            Label {
                Text("預設關閉。絕不包含位置、搜尋、路線、配對資料或個人資訊。")
            } icon: {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.green)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

private struct OnboardingPage {
    let symbol: String
    let title: String
    let message: String
    let colors: [Color]
    let showsUsageStatisticsControl: Bool

    init(
        symbol: String,
        title: String,
        message: String,
        colors: [Color],
        showsUsageStatisticsControl: Bool = false
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.colors = colors
        self.showsUsageStatisticsControl = showsUsageStatisticsControl
    }

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "location.viewfinder",
            title: "歡迎使用 Roam Control",
            message: "在地圖上選擇你的 iPhone 要顯示的位置。",
            colors: [.blue, .cyan]
        ),
        OnboardingPage(
            symbol: "map.fill",
            title: "選擇任何地點",
            message: "搜尋目的地或點選地圖，然後將其儲存為目標。",
            colors: [.indigo, .blue]
        ),
        OnboardingPage(
            symbol: "iphone.and.arrow.forward",
            title: "只需配對此 iPhone 一次",
            message: "Roam Control 需要先完成一次私人配對才能控制位置。接下來會引導你完成設定。",
            colors: [.green, .teal]
        ),
        OnboardingPage(
            symbol: "hand.raised.fill",
            title: "以隱私為核心",
            message: "你可以選擇是否透過匿名活動計數協助改善 Roam Control。只有在你開啟後才會開始分享，也可以之後在設定中變更。",
            colors: [.indigo, .purple],
            showsUsageStatisticsControl: true
        )
    ]
}

#Preview {
    OnboardingView()
        .environment(AppModel())
}
