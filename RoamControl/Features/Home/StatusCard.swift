import SwiftUI

struct StatusCard: View {
    let state: ConnectionState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        switch state {
        case .notConfigured: "尚未設定"
        case .ready: "準備完成"
        case .connecting: "連線中"
        case .active: "位置工作階段進行中"
        case .failed: "連線錯誤"
        }
    }

    private var detail: String {
        switch state {
        case .notConfigured: "目前尚未加入配對支援。"
        case .ready: "The paired device is available."
        case .connecting: "Roam Control is preparing the secure device session."
        case .active: "Roam Control is controlling the session."
        case .failed(let message): message
        }
    }

    private var iconName: String {
        switch state {
        case .notConfigured: "circle.dashed"
        case .ready: "checkmark.circle.fill"
        case .connecting: "arrow.triangle.2.circlepath"
        case .active: "location.fill"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private var tint: Color {
        switch state {
        case .notConfigured: .secondary
        case .ready: .green
        case .connecting: .blue
        case .active: .blue
        case .failed: .red
        }
    }
}
