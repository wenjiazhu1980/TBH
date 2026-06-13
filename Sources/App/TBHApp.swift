import SwiftUI

@main
enum Main {
    static func main() {
        #if DEBUG
        if CommandLine.arguments.contains("--self-test") {
            SelfTest.runAll()
        }
        #endif
        TBHApp.main()
    }
}

struct TBHApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var gameEngine: GameEngine = {
        let engine = GameEngine()
        engine.start()
        return engine
    }()

    var body: some Scene {
        // 菜单栏常驻
        MenuBarExtra {
            MenuBarPopover(gameEngine: gameEngine)
        } label: {
            MenuBarIcon(hero: gameEngine.hero)
        }
        .menuBarExtraStyle(.window)
    }
}

/// AppDelegate 处理生命周期事件
/// 注意：退出时的保存由 GameEngine 监听 willTerminateNotification 处理
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 防止系统因 App Nap 自动终止游戏
        ProcessInfo.processInfo.disableAutomaticTermination("Game is running")
    }
}
