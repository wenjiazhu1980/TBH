import SwiftUI
import AppKit

/// 菜单栏图标 — 保持原生菜单栏尺寸，完整状态放在弹窗内展示。
struct MenuBarIcon: View {
    static let nativeIconSide: CGFloat = 14
    static let nativeLabelHeight: CGFloat = 18

    @ObservedObject var hero: Hero

    var body: some View {
        HStack(spacing: 4) {
            if hero.isAlive, let nsImage = NSImage.loadExtracted(named: GameArt.appIconName) {
                Image(nsImage: nsImage.menuBarIconSized(to: Self.nativeIconSide))
                    .interpolation(.none)
                    .antialiased(false)
                    .frame(width: Self.nativeIconSide, height: Self.nativeIconSide)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: Self.nativeIconSide, height: Self.nativeIconSide)
            }

            Text("Lv.\(hero.level)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .frame(height: Self.nativeLabelHeight)
        .fixedSize()
    }
}

private extension NSImage {
    /// 状态栏会按 NSImage 的点尺寸参与布局；保留原始位图，只收紧布局尺寸。
    func menuBarIconSized(to side: CGFloat) -> NSImage {
        let image = (copy() as? NSImage) ?? self
        image.size = NSSize(width: side, height: side)
        image.isTemplate = false
        return image
    }
}
