import SwiftUI
import AppKit

/// 像素精灵渲染器 — 从提取的素材加载并显示像素美术
struct PixelSprite: View {
    let imageName: String
    var size: CGSize = CGSize(width: 64, height: 64)

    var body: some View {
        if let nsImage = NSImage.loadExtracted(named: imageName) {
            Image(nsImage: nsImage)
                .resizable()
                .interpolation(.none)  // 关键：禁用插值保持像素锐利
                .antialiased(false)
                .frame(width: size.width, height: size.height)
        } else {
            // 占位符
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size.width, height: size.height)
                .overlay(
                    Image(systemName: "questionmark")
                        .foregroundColor(.secondary)
                )
        }
    }
}

/// 战斗场景精灵
struct BattleSprite: View {
    let monsterID: String
    var size: CGSize = CGSize(width: 64, height: 64)
    @State private var phase = 0

    var body: some View {
        PixelSprite(imageName: MonsterArt.spriteName(for: monsterID), size: size)
            .offset(y: phase == 0 ? -2 : 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    phase = 1
                }
            }
    }
}

/// 怪物 ID → 素材名映射
enum MonsterArt {
    static func spriteName(for monsterID: String) -> String {
        switch monsterID {
        case "skeleton", "zombie", "golem", "dragon_whelp":
            return "monster_skeleton_boss"
        default:
            // slime/goblin/wolf/bat/spider 暂用史莱姆占位
            return "monster_slime_red"
        }
    }
}

// MARK: - 资源加载辅助

extension NSImage {
    private static let extractedSubdirectory = "Extracted"

    /// 从 Extracted 素材目录加载图片。
    /// 查找顺序：SPM 资源 bundle（子目录/展平两种布局）→ 仓库内开发路径（由源码位置推导，不含硬编码用户路径）。
    static func loadExtracted(named name: String) -> NSImage? {
        guard !name.isEmpty else { return nil }

        if let url = Bundle.module.url(forResource: name, withExtension: "png", subdirectory: extractedSubdirectory)
                  ?? Bundle.module.url(forResource: name, withExtension: "png") {
            return NSImage(contentsOf: url)
        }

        // 开发 fallback：从本源文件位置推导仓库根目录
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Components
            .deletingLastPathComponent()  // UI
            .deletingLastPathComponent()  // Sources
            .deletingLastPathComponent()  // 仓库根
        let devURL = repoRoot.appendingPathComponent("Sources/Resources/\(extractedSubdirectory)/\(name).png")
        return NSImage(contentsOf: devURL)
    }
}
