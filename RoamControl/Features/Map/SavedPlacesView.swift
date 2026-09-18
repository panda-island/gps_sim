import SwiftUI

struct SavedPlacesView: View {
    private enum ClearTarget: String, Identifiable {
        case favourites
        case history

        var id: Self { self }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var favouriteBeingRenamed: LocationTarget?
    @State private var favouriteName = ""
    @State private var clearTarget: ClearTarget?
    @State private var editMode: EditMode = .inactive

    let favourites: [LocationTarget]
    let history: [LocationTarget]
    let shouldShowFavouriteReorderHint: Bool
    let isFavourite: (LocationTarget) -> Bool
    let onSelect: (LocationTarget) -> Void
    let onToggleFavourite: (LocationTarget) -> Void
    let onDeleteFavourite: (LocationTarget) -> Void
    let onMoveFavourites: (IndexSet, Int) -> Void
    let onDismissFavouriteReorderHint: () -> Void
    let onRenameFavourite: (LocationTarget, String) -> Void
    let onDeleteHistory: (LocationTarget) -> Void
    let onClearFavourites: () -> Void
    let onClearHistory: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if favourites.isEmpty {
                        EmptySavedPlacesRow(
                            symbol: "heart",
                            message: "點選選取地點上的愛心即可儲存。"
                        )
                    } else {
                        ForEach(favourites) { location in
                            SavedPlaceRow(
                                location: location,
                                symbol: "heart.fill",
                                isFavourite: true,
                                onSelect: { select(location) },
                                onToggleFavourite: { onToggleFavourite(location) }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    onDeleteFavourite(location)
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }

                                Button {
                                    beginRenaming(location)
                                } label: {
                                    Label("重新命名", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                        .onMove(perform: onMoveFavourites)
                    }
                } header: {
                    HStack {
                        Text("最愛")
                        Spacer()
                        if !favourites.isEmpty {
                            Button("清除") {
                                clearTarget = .favourites
                            }
                            .textCase(nil)
                        }
                    }
                } footer: {
                    if shouldShowFavouriteReorderHint && favourites.count >= 2 {
                        Text("點選「編輯」重新排列最愛。")
                    }
                }

                Section {
                    if history.isEmpty {
                        EmptySavedPlacesRow(
                            symbol: "clock",
                            message: "Places you use will appear here."
                        )
                    } else {
                        ForEach(history) { location in
                            SavedPlaceRow(
                                location: location,
                                symbol: "clock.fill",
                                isFavourite: isFavourite(location),
                                onSelect: { select(location) },
                                onToggleFavourite: { onToggleFavourite(location) }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    onDeleteHistory(location)
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("歷史紀錄")
                        Spacer()
                        if !history.isEmpty {
                            Button("清除") {
                                clearTarget = .history
                            }
                                .textCase(nil)
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("已儲存的位置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !favourites.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(editMode.isEditing ? "完成" : "編輯") {
                            if !editMode.isEditing {
                                onDismissFavouriteReorderHint()
                            }
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                            .accessibilityLabel("重新排列最愛")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .alert(
                "Rename Favourite",
                isPresented: Binding(
                    get: { favouriteBeingRenamed != nil },
                    set: { if !$0 { favouriteBeingRenamed = nil } }
                )
            ) {
                TextField("最愛名稱", text: $favouriteName)
                Button("取消", role: .cancel) {
                    favouriteBeingRenamed = nil
                }
                Button("儲存") {
                    guard let favouriteBeingRenamed else { return }
                    onRenameFavourite(favouriteBeingRenamed, favouriteName)
                    self.favouriteBeingRenamed = nil
                }
                .disabled(favouriteName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: {
                Text("為這個已儲存的地點取一個容易辨識的名稱。")
            }
            .confirmationDialog(
                clearConfirmationTitle,
                isPresented: Binding(
                    get: { clearTarget != nil },
                    set: { if !$0 { clearTarget = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(clearConfirmationButton, role: .destructive) {
                    performClear()
                }
                Button("取消", role: .cancel) {
                    clearTarget = nil
                }
            } message: {
                Text(clearConfirmationMessage)
            }
        }
    }

    private func select(_ location: LocationTarget) {
        onSelect(location)
        dismiss()
    }

    private func beginRenaming(_ location: LocationTarget) {
        favouriteName = location.name
        favouriteBeingRenamed = location
    }

    private var clearConfirmationTitle: String {
        switch clearTarget {
        case .favourites: "要清除所有最愛嗎？"
        case .history: "要清除位置歷史紀錄嗎？"
        case nil: "要清除已儲存的位置嗎？"
        }
    }

    private var clearConfirmationButton: String {
        switch clearTarget {
        case .favourites: "清除最愛"
        case .history: "清除歷史紀錄"
        case nil: "清除"
        }
    }

    private var clearConfirmationMessage: String {
        switch clearTarget {
        case .favourites: "所有最愛都會被移除，但歷史紀錄會保留。"
        case .history: "所有最近使用的位置都會被移除，但最愛會保留。"
        case nil: "此操作無法復原。"
        }
    }

    private func performClear() {
        switch clearTarget {
        case .favourites:
            onClearFavourites()
        case .history:
            onClearHistory()
        case nil:
            break
        }
        clearTarget = nil
    }
}

private struct SavedPlaceRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let location: LocationTarget
    let symbol: String
    let isFavourite: Bool
    let onSelect: () -> Void
    let onToggleFavourite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onSelect) {
                HStack(spacing: 12) {
                    Image(systemName: symbol)
                        .foregroundStyle(symbol.hasPrefix("heart") ? .pink : .blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(location.name)
                            .foregroundStyle(.primary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                        Text(location.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(locationAccessibilityLabel)
            .accessibilityHint("選取此位置")

            Button(action: onToggleFavourite) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavourite ? .pink : .secondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavourite ? "Remove from favourites" : "加入最愛")
        }
    }

    private var locationAccessibilityLabel: String {
        guard !location.subtitle.isEmpty else { return location.name }
        return "\(location.name), \(location.subtitle)"
    }
}

private struct EmptySavedPlacesRow: View {
    let symbol: String
    let message: String

    var body: some View {
        Label(message, systemImage: symbol)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
    }
}
