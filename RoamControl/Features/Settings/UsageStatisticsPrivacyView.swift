import SwiftUI

struct UsageStatisticsPrivacyView: View {
    var body: some View {
        List {
            Section {
                Label {
                    Text("啟用分享後，Roam Control 只會傳送少量且固定的匿名活動計數。")
                } icon: {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                }
            }

            Section("已分享") {
                privacyRow("雜湊後的隨機安裝識別碼", symbol: "number.circle")
                privacyRow("事件的大約時間", symbol: "clock")
                privacyRow("App 已開啟或回到前景", symbol: "app.badge.checkmark")
                privacyRow("App 版本與建置編號", symbol: "number")
                privacyRow("已完成介紹", symbol: "sparkles")
                privacyRow("連線說明、重試與重試成功次數", symbol: "arrow.clockwise")
                privacyRow("固定失敗階段、排程器原因、操作與復原類別", symbol: "exclamationmark.triangle")
                privacyRow("排程失敗時的固定配對與位置工作任務設定、註冊狀態", symbol: "gearshape.2")
                privacyRow("背景工作階段支援、權限狀態與排程器可用性", symbol: "location.circle")
                privacyRow("iOS 版本（僅提供給維護服務）", symbol: "iphone")
                privacyRow("排程失敗時的已安裝 App 與允許的背景任務識別碼（僅提供給維護服務）", symbol: "gearshape")
                privacyRow("配對完成", symbol: "iphone.and.arrow.forward")
                privacyRow("固定位置或步行工作階段已開始", symbol: "figure.walk")
                privacyRow("目前位置已更新", symbol: "location.fill")
            }

            Section("從不分享") {
                privacyRow("座標或地點名稱", symbol: "mappin.slash")
                privacyRow("搜尋、最愛、歷史紀錄或路線", symbol: "magnifyingglass")
                privacyRow("配對紀錄或 PIN 碼", symbol: "key.slash")
                privacyRow("Apple ID、裝置名稱或個人資料", symbol: "person.crop.circle.badge.xmark")
                privacyRow("原始錯誤訊息或憑證", symbol: "lock.shield")
                privacyRow("完整診斷報告", symbol: "doc.text.magnifyingglass")
            }

            Section("儲存空間與控制") {
                Text("此安裝會建立一組隨機識別碼，傳送前會以不可逆方式進行雜湊。它僅用於估算參與安裝的活動量。")
                    .foregroundStyle(.secondary)

                Text("關閉分享後會停止新的資料回報、在可能的情況下取消進行中的請求，並從 Roam Control 移除識別碼。但無法撤回已收到的匿名事件。")
                    .foregroundStyle(.secondary)

                Text("事件會傳送至 Roam Control 維護者營運的服務；在設定為 Beta 的版本中，也會傳送至 TelemetryDeck。自架服務會收到一般 HTTPS 連線中繼資料，例如來源 IP 位址，但 App 不會將其放入事件內容。")
                    .foregroundStyle(.secondary)

                Text("自架服務每天執行維護，刪除超過 90 天的即時事件。資料庫備份或網頁伺服器存取記錄沒有固定的刪除時間承諾。TelemetryDeck 表示不會儲存 IP 位址，匿名事件可能保留約 7–10 年，但不保證確切刪除日期。")
                    .foregroundStyle(.secondary)

                Text("Roam Control 使用精簡的第一方傳送機制，而非分析 SDK，因此不會自動加入額外的裝置中繼資料。")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("匿名統計資料")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacyRow(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
    }
}

#Preview {
    NavigationStack {
        UsageStatisticsPrivacyView()
    }
}
