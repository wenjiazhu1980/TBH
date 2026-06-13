import Foundation

/// 背包
class Inventory: ObservableObject, Codable {
    @Published var items: [Item] = []
    let maxCapacity: Int

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

    // MARK: - Codable
    enum CodingKeys: String, CodingKey { case items, maxCapacity }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _items = Published(initialValue: try c.decode([Item].self, forKey: .items))
        maxCapacity = try c.decodeIfPresent(Int.self, forKey: .maxCapacity) ?? 50
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(items, forKey: .items)
        try c.encode(maxCapacity, forKey: .maxCapacity)
    }

    init() {
        _items = Published(initialValue: [])
        maxCapacity = 50
    }
}
