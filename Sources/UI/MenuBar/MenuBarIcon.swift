import SwiftUI

/// 菜单栏图标 — 显示英雄像素精灵
struct MenuBarIcon: View {
    @ObservedObject var hero: Hero

    var body: some View {
        HStack(spacing: 3) {
            // 像素英雄图标
            if let nsImage = NSImage.loadExtracted(named: heroSpriteName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.none)
                    .antialiased(false)
                    .frame(width: 16, height: 16)
            } else {
                // 后备：使用 SF Symbol
                Image(systemName: hero.isAlive ? "figure.fencing" : "skull")
                    .font(.system(size: 12))
                    .foregroundColor(heroColor)
            }

            // 等级
            Text("Lv.\(hero.level)")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            // 简易血条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                    Rectangle()
                        .fill(hero.currentHP > hero.maxHP / 4 ? Color.green : Color.red)
                        .frame(width: geo.size.width * hpPercentage)
                }
            }
            .frame(width: 24, height: 3)
            .cornerRadius(1)
        }
    }

    private var hpPercentage: CGFloat {
        guard hero.maxHP > 0 else { return 0 }
        return CGFloat(hero.currentHP) / CGFloat(hero.maxHP)
    }

    private var heroSpriteName: String {
        if !hero.isAlive { return "monster_skeleton_boss" }  // 死亡用骷髅
        return "hero_knight"  // MVP 只有战士
    }

    private var heroColor: Color {
        if !hero.isAlive { return .gray }
        if hero.currentHP < hero.maxHP / 4 { return .red }
        return .blue
    }
}
