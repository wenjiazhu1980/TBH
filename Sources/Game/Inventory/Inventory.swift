import Foundation

/// 背包
class Inventory: ObservableObject, Codable {
    static let baseCapacity = 50

    @Published var items: [Item] = []
    @Published private(set) var maxCapacity: Int

    var isFull: Bool { items.count >= maxCapacity }

    /// 添加物品；背包已满时返回 false，物品不会被静默丢弃
    @discardableResult
    func add(_ item: Item) -> Bool {
        guard !isFull else { return false }
        items.append(item)
        return true
    }

    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }

    func remove(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }

    func setMaxCapacity(_ capacity: Int) {
        maxCapacity = max(Self.baseCapacity, capacity)
    }

    @discardableResult
    func discard(_ item: Item) -> Bool {
        guard !item.isLocked else { return false }
        let oldCount = items.count
        remove(item)
        return items.count < oldCount
    }

    @discardableResult
    func toggleLock(_ item: Item) -> Item? {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return nil }
        let updated = items[index].locked(!items[index].isLocked)
        items[index] = updated
        return updated
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey { case items, maxCapacity }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _items = Published(initialValue: try c.decode([Item].self, forKey: .items))
        _maxCapacity = Published(initialValue: try c.decodeIfPresent(Int.self, forKey: .maxCapacity) ?? Self.baseCapacity)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(items, forKey: .items)
        try c.encode(maxCapacity, forKey: .maxCapacity)
    }

    init() {
        _items = Published(initialValue: [])
        _maxCapacity = Published(initialValue: Self.baseCapacity)
    }
}
