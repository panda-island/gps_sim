import SwiftUI

struct SettingsView: View {
    private static let bugReportURL = URL(
        string: "https://github.com/seanhowarthdev/Roam-Control/issues/new?template=bug_report.yml"
    )!
    private static let featureRequestURL = URL(
        string: "https://github.com/seanhowarthdev/Roam-Control/issues/new?template=feature_request.yml"
    )!

    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isShowingDeviceSetup = false
    @State private var isReplayingOnboarding = false
    @State private var isConfirmingReset = false
    @State private var resetError: String?
    @State private var releaseUpdateStatus: ReleaseUpdateStatus = .idle

    var body: some View {
        NavigationStack {
            Form {
                Section("外觀") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("主題")
                            .font(.subheadline.weight(.medium))

                        themePicker
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("地圖樣式")
                            .font(.subheadline.weight(.medium))

                        mapStylePicker
                    }
                    .padding(.vertical, 4)
                }

                Section("裝置") {
                    NavigationLink {
                        ConnectionHealthView()
                            .environment(appModel)
                    } label: {
                        Label("連線狀態", systemImage: "stethoscope")
                    }

                    Button {
                        isShowingDeviceSetup = true
                    } label: {
                        Label {
                            pairingConnectionLabel
                        } icon: {
                            Image(systemName: "iphone.and.arrow.forward")
                        }
                    }
                    .foregroundStyle(.primary)
                }

                Section {
                    Toggle(
                        "分享匿名使用統計",
                        isOn: anonymousUsageStatisticsBinding
                    )

                    NavigationLink {
                        UsageStatisticsPrivacyView()
                    } label: {
                        Label("分享哪些資料", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Text("隱私權")
                } footer: {
                    Text("此功能為選用且預設關閉。可協助估算參與安裝的使用情況，絕不包含位置、搜尋或配對資料。")
                }

                Section("關於") {
                    NavigationLink {
                        AboutRoamControlView()
                    } label: {
                        Label("關於 Roam Control", systemImage: "info.circle")
                    }

                    LabeledContent("版本", value: versionText)
                    LabeledContent("建置", value: buildNumberText)
                    LabeledContent("建置時間", value: buildDateText)

                    Button {
                        isReplayingOnboarding = true
                    } label: {
                        Label("重新查看介紹", systemImage: "sparkles")
                    }
                    .foregroundStyle(.primary)
                }

                Section {
                    Button {
                        Task { await checkForUpdates() }
                    } label: {
                        Label(updateCheckTitle, systemImage: updateCheckSymbol)
                    }
                    .disabled(releaseUpdateStatus == .checking)

                    updateStatusDetail
                } header: {
                    Text("更新")
                } footer: {
                    Text("只有在你點選時才會檢查 GitHub 公開版本。Roam Control 不會在此請求中傳送位置、配對或診斷資料。")
                }

                Section {
                    Link(destination: Self.bugReportURL) {
                        Label("回報錯誤", systemImage: "ladybug")
                    }

                    Link(destination: Self.featureRequestURL) {
                        Label("提出功能建議", systemImage: "lightbulb")
                    }
                } header: {
                    Text("意見回饋")
                } footer: {
                    Text("GitHub 可能會先要求你選擇「回報錯誤」或「提出功能建議」。若是配對或連線問題，請開啟「連線狀態」並使用「複製診斷資料」。請勿包含配對紀錄、憑證或私人位置。")
                }

                Section {
                    Button("重設 Roam Control", role: .destructive) {
                        isConfirmingReset = true
                    }
                } footer: {
                    Text("這會清除配對紀錄與本機 App 設定，然後再次顯示導覽。不會移除或變更 LocalDevVPN。")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .sheet(isPresented: $isShowingDeviceSetup) {
            PairingSetupView()
                .environment(appModel)
        }
        .fullScreenCover(isPresented: $isReplayingOnboarding) {
            OnboardingView(isReplay: true)
                .environment(appModel)
        }
        .confirmationDialog(
            "要重設 Roam Control 嗎？",
            isPresented: $isConfirmingReset,
            titleVisibility: .visible
        ) {
            Button("重設 App", role: .destructive) {
                Task { await resetApp() }
            }
        } message: {
            Text("你的配對紀錄與本機設定將被移除，之後會返回歡迎畫面。")
        }
        .alert("無法完成重設", isPresented: isShowingResetError) {
            Button("好", role: .cancel) {
                resetError = nil
            }
        } message: {
            Text(resetError ?? "請再試一次。")
        }
    }

    private var connectionLabel: String {
        switch appModel.connectionState {
        case .notConfigured: "尚未配對"
        case .ready: "準備完成"
        case .connecting: "連線中"
        case .active: "啟用中"
        case .failed: "有問題"
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch appModel.appearance {
        case .automatic: nil
        case .light: .light
        case .dark: .dark
        }
    }

    private var appearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { appModel.appearance },
            set: appModel.setAppearance
        )
    }

    @ViewBuilder
    private var themePicker: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Picker("主題", selection: appearanceBinding) {
                ForEach(AppAppearance.allCases) { appearance in
                    Label(appearance.title, systemImage: appearance.systemImage)
                        .tag(appearance)
                }
            }
            .pickerStyle(.menu)
        } else {
            Picker("主題", selection: appearanceBinding) {
                ForEach(AppAppearance.allCases) { appearance in
                    Label(appearance.title, systemImage: appearance.systemImage)
                        .tag(appearance)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var mapStylePicker: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Picker("地圖樣式", selection: mapStyleBinding) {
                ForEach(MapDisplayStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.menu)
        } else {
            Picker("地圖樣式", selection: mapStyleBinding) {
                ForEach(MapDisplayStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var pairingConnectionLabel: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 3) {
                Text("配對與連線")
                Text(connectionLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack {
                Text("配對與連線")
                Spacer()
                Text(connectionLabel)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var mapStyleBinding: Binding<MapDisplayStyle> {
        Binding(
            get: { appModel.mapDisplayStyle },
            set: appModel.setMapDisplayStyle
        )
    }

    private var anonymousUsageStatisticsBinding: Binding<Bool> {
        Binding(
            get: { appModel.sharesAnonymousUsageStatistics },
            set: appModel.setSharesAnonymousUsageStatistics
        )
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return version ?? "1.0"
    }

    private var buildNumberText: String {
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return build ?? "未知"
    }

    private var buildDateText: String {
        if
            let timestamp = Bundle.main.object(
                forInfoDictionaryKey: "RoamControlBuildTimestamp"
            ) as? String,
            let buildDate = ISO8601DateFormatter().date(from: timestamp)
        {
            return buildDate.formatted(date: .abbreviated, time: .shortened)
        }

        guard
            let executableURL = Bundle.main.executableURL,
            let values = try? executableURL.resourceValues(forKeys: [.contentModificationDateKey]),
            let buildDate = values.contentModificationDate
        else { return "未知" }

        return buildDate.formatted(date: .abbreviated, time: .shortened)
    }

    private var updateCheckTitle: String {
        switch releaseUpdateStatus {
        case .checking: "正在檢查更新⋯"
        default: "檢查更新"
        }
    }

    private var updateCheckSymbol: String {
        releaseUpdateStatus == .checking ? "arrow.triangle.2.circlepath" : "arrow.down.circle"
    }

    @ViewBuilder
    private var updateStatusDetail: some View {
        switch releaseUpdateStatus {
        case .idle, .checking:
            EmptyView()
        case .updateAvailable(let release):
            Link(destination: release.releaseURL) {
                Label("安裝 \(release.version)", systemImage: "arrow.up.right.square")
            }
            Text("有較新的公開版本可用：\(release.name)。")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .current(let release):
            Label("你已使用最新的公開版本（\(release.version)）。", systemImage: "checkmark.circle")
                .font(.subheadline)
                .foregroundStyle(.green)
        case .newerLocalBuild(let release):
            Link(destination: release.releaseURL) {
                Label("查看公開版本 \(release.version)", systemImage: "arrow.up.right.square")
            }
            Text("你正在使用較新的本機測試版本（\(versionText) 建置 \(buildNumberText)）。")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .noPublishedRelease:
            Label("目前尚未發布公開的 GitHub 版本。", systemImage: "clock")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .unavailable:
            Label("目前無法檢查 GitHub，請稍後再試。", systemImage: "exclamationmark.triangle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @MainActor
    private func checkForUpdates() async {
        releaseUpdateStatus = .checking

        do {
            let release = try await ReleaseUpdateChecker().latestRelease()
            if VersionComparison.isRemoteVersionNewer(release.version, than: versionText) {
                releaseUpdateStatus = .updateAvailable(release)
            } else if VersionComparison.isRemoteVersionNewer(versionText, than: release.version) {
                releaseUpdateStatus = .newerLocalBuild(release)
            } else {
                releaseUpdateStatus = .current(release)
            }
        } catch ReleaseUpdateCheckError.noPublishedRelease {
            releaseUpdateStatus = .noPublishedRelease
        } catch {
            releaseUpdateStatus = .unavailable
        }
    }

    private var isShowingResetError: Binding<Bool> {
        Binding(
            get: { resetError != nil },
            set: { if !$0 { resetError = nil } }
        )
    }

    @MainActor
    private func resetApp() async {
        do {
            try await appModel.resetApp()
            dismiss()
        } catch {
            resetError = error.localizedDescription
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppModel())
}
