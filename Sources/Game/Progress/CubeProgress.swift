import Foundation

/// Cube 进度。当前只累计已核对的物品 Cube XP，不推断原版等级奖励公式。
struct CubeProgress: Codable, Equatable {
    private(set) var totalExperience: Int = 0
    private(set) var infusedItemCount: Int = 0

    var displayText: String {
        "\(totalExperience) XP"
    }

    mutating func infuse(_ item: Item) -> Int {
        let gainedExperience = item.rarity.cubeExperience
        totalExperience += gainedExperience
        infusedItemCount += 1
        return gainedExperience
    }
}
