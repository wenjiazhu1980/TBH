import SwiftUI
import AppKit

/// 菜单栏图标 — 保持原生菜单栏尺寸，完整状态放在弹窗内展示。
struct MenuBarIcon: View {
    @ObservedObject var hero: Hero

    var body: some View {
        HStack(spacing: 4) {
            if hero.isAlive, let nsImage = NSImage.loadExtracted(named: GameArt.appIconName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.none)
                    .antialiased(false)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
            } else {
                Image(systemName: "skull")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 12, weight: .semibold))
            }

            Text("Lv.\(hero.level)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .fixedSize()
    }
}
