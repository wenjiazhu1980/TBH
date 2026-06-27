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
                .aspectRatio(contentMode: .fit)
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

    var body: some View {
        PixelSprite(imageName: GameArt.monsterSpriteName(for: monsterID), size: size)
    }
}

// MARK: - 资源加载辅助

extension NSImage {
    private static let extractedSubdirectory = "Extracted"
    private static let resourceBundleName = "TBH-macOS_TBH.bundle"

    /// 图片缓存 — 避免 SwiftUI 每次 diff 时重复从磁盘加载并解码 PNG。
    /// 使用 NSCache 自动在内存压力下逐出条目，无需手动管理。
    private static let imageCache = NSCache<NSString, NSImage>()

    /// 从 Extracted 素材目录加载图片（带缓存）。
    /// 查找顺序：打包后的 .app Resources → SwiftPM 构建目录 → 仓库内开发路径。
    static func loadExtracted(named name: String) -> NSImage? {
        guard !name.isEmpty else { return nil }

        let cacheKey = name as NSString
        if let cached = imageCache.object(forKey: cacheKey) {
            return cached
        }

        let loaded = loadExtractedFromDisk(named: name)
        if let loaded {
            imageCache.setObject(loaded, forKey: cacheKey)
        }
        return loaded
    }

    private static func loadExtractedFromDisk(named name: String) -> NSImage? {
        for bundle in resourceBundles() {
            if let url = bundle.url(forResource: name, withExtension: "png", subdirectory: extractedSubdirectory)
                      ?? bundle.url(forResource: name, withExtension: "png"),
               let image = NSImage(contentsOf: url) {
                return image
            }
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

    private static func resourceBundles() -> [Bundle] {
        var seen = Set<String>()
        var candidates: [URL] = []

        func append(_ url: URL?) {
            guard let url else { return }
            let path = url.standardizedFileURL.path
            guard seen.insert(path).inserted else { return }
            candidates.append(url)
        }

        append(Bundle.main.resourceURL?.appendingPathComponent(resourceBundleName))
        append(Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent(resourceBundleName))
        append(Bundle.main.bundleURL.appendingPathComponent(resourceBundleName))

        return candidates.compactMap { Bundle(url: $0) }
    }
}
