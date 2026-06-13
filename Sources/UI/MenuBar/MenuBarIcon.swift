import SwiftUI

/// 菜单栏图标 — 保持原生菜单栏尺寸，完整状态放在弹窗内展示。
struct MenuBarIcon: View {
    @ObservedObject var hero: Hero

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: hero.isAlive ? "figure.fencing" : "skull")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 12, weight: .semibold))

            Text("Lv.\(hero.level)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .fixedSize()
    }
}
