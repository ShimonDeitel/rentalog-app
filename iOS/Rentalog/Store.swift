import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [RentalogEntry] = []
    @Published var isPro: Bool = false

    /// Free tier allows this many entries. Seed data is always fewer than this
    /// so a fresh install never hits the paywall immediately.
    static let freeLimit = 12

    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("Rentalog", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        fileURL = dir.appendingPathComponent("entries.json")
        load()
        if entries.isEmpty {
            seed()
            save()
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(_ entry: RentalogEntry) -> Bool {
        guard canAddMore else { return false }
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: RentalogEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: RentalogEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func seed() {
        let now = Date()
        entries = [
            RentalogEntry(customerName: "Sample Customer", amount: 250, note: "Example rental entry", date: now, status: .open),
            RentalogEntry(customerName: "Another Customer", amount: 100, note: "Second sample", date: now.addingTimeInterval(-86400), status: .closed)
        ]
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([RentalogEntry].self, from: data) {
            entries = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
