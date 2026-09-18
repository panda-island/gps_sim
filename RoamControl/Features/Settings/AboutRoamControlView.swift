import SwiftUI

struct AboutRoamControlView: View {
    var body: some View {
        List {
            appSummary
            quickStart

            Section("選擇位置") {
                guideRow(
                    "搜尋",
                    symbol: "magnifyingglass",
                    text: "Find a place by name or enter latitude and longitude. Choosing a result also clears the search ready for the next one."
                )
                guideRow(
                    "點選地圖",
                    symbol: "hand.tap",
                    text: "Drop a precise pin anywhere on the map. The close button on its card clears that pin."
                )
                guideRow(
                    "最愛",
                    symbol: "heart",
                    text: "Save the selected place for quick use later. Favourites can be renamed, reordered or removed from the saved-locations screen."
                )
                guideRow(
                    "最愛與歷史紀錄",
                    symbol: "list.bullet.rectangle",
                    text: "Open saved favourites and recently used locations. Swipe an item to remove it."
                )
            }

            Section("地圖控制項") {
                guideRow(
                    "目前位置",
                    symbol: "location.fill",
                    text: "Fly back to this iPhone’s real location and return the map to north-up."
                )
                guideRow(
                    "指南針",
                    symbol: "safari",
                    text: "Appears when the map is rotated. It shows the map heading; tap it to face north again."
                )
                guideRow(
                    "連線狀態",
                    symbol: "circle.fill",
                    text: "Shows whether Roam Control is ready, connecting or active. Tap it for pairing and connection details."
                )
                guideRow(
                    "設定",
                    symbol: "gearshape.fill",
                    text: "Change appearance and map style, check the connection, manage pairing and view app information."
                )
            }

            Section("位置控制") {
                guideRow(
                    "開始位置控制",
                    symbol: "location.fill",
                    text: "開始將選取地點回報為此 iPhone 的位置。LocalDevVPN 必須已連線。"
                )
                guideRow(
                    "更新位置",
                    symbol: "arrow.triangle.2.circlepath",
                    text: "Move an active location session to a newly selected place without restarting the whole connection flow."
                )
                guideRow(
                    "停止並還原",
                    symbol: "location.slash.fill",
                    text: "結束目前工作階段並還原此 iPhone 實際位置前先確認。"
                )
                guideRow(
                    "行動數據提示",
                    symbol: "antenna.radiowaves.left.and.right",
                    text: "When using mobile data, temporarily turn it off when asked. Roam Control continues automatically once the local connection is available, and tells you when data can go back on."
                )
                guideRow(
                    "中斷工作階段復原",
                    symbol: "arrow.trianglehead.2.clockwise.rotate.90",
                    text: "If Roam Control did not receive a normal end signal, the next launch offers to resume, reconnect briefly to restore the real location, or confirm that it is already back."
                )
            }

            Section("步行路線") {
                guideRow(
                    "Preview Walking Route",
                    symbol: "figure.walk",
                    text: "Ask Apple Maps for a walking route from your current point to the selected destination before anything starts."
                )
                guideRow(
                    "步行速度",
                    symbol: "speedometer",
                    text: "選擇模擬位置沿路線移動的速度。"
                )
                guideRow(
                    "開始步行",
                    symbol: "figure.walk.motion",
                    text: "Begin moving the reported location along the previewed route. The walk can continue while you use another app."
                )
                guideRow(
                    "暫停或繼續",
                    symbol: "pause.fill",
                    text: "Hold the current point on the route, then continue from exactly where it paused."
                )
                guideRow(
                    "沿路線返回",
                    symbol: "arrow.uturn.backward",
                    text: "抵達後反向行走，沿原路返回。"
                )
                guideRow(
                    "新位置",
                    symbol: "mappin.and.ellipse",
                    text: "Keep the active session and return to the map so you can choose another destination."
                )
                guideRow(
                    "停止並還原",
                    symbol: "stop.fill",
                    text: "停止步行、清除路線並還原實際位置。確認視窗可避免誤觸停止。"
                )
            }

            Section("設定與支援") {
                guideRow(
                    "配對與連線",
                    symbol: "iphone.and.arrow.forward",
                    text: "Pair this iPhone once so Roam Control can identify it through LocalDevVPN."
                )
                guideRow(
                    "連線狀態",
                    symbol: "stethoscope",
                    text: "Check pairing and the local connection without changing your location. You can also share a readable diagnostics report."
                )
                guideRow(
                    "重新查看介紹",
                    symbol: "sparkles",
                    text: "再次查看導覽，不會刪除你的配對、最愛、歷史紀錄或偏好設定。"
                )
                guideRow(
                    "重設 Roam Control",
                    symbol: "arrow.counterclockwise",
                    text: "Erase the pairing record and all saved app choices, then return to onboarding. LocalDevVPN itself is not changed."
                )
            }
        }
        .navigationTitle("關於 Roam Control")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appSummary: some View {
        Section {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 74, height: 74)

                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                }

                VStack(spacing: 5) {
                    Text("Roam Control")
                        .font(.title2.bold())

                    Text("在簡潔的地圖上選擇、測試並移動此 iPhone 回報的位置。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .accessibilityElement(children: .combine)
        }
    }

    private var quickStart: some View {
        Section {
            stepRow(1, "Pair this iPhone once.")
            stepRow(2, "連線至 LocalDevVPN。")
            stepRow(3, "搜尋、選擇或放置位置。")
            stepRow(4, "開始固定位置，或預覽步行路線。")
        } header: {
            Text("運作方式")
        } footer: {
            Text("Roam Control is intended for location-based app development and testing on your own device.")
        }
    }

    private func stepRow(_ number: Int, _ text: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.blue, in: Circle())

            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("步驟 \(number)：\(text)")
    }

    private func guideRow(_ title: String, symbol: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 26, height: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(text)")
    }
}

#Preview {
    NavigationStack {
        AboutRoamControlView()
    }
}
