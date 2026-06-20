import Testing
import AppKit
@testable import TBH

@Suite struct ControlsTests {
    @Test func popoverScaleResetAndClampStayDeterministic() {
        let defaultSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.defaultScale)
        let minimumSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.minimumScale)
        let maximumSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.maximumScale)

        #expect(defaultSize == MenuBarPopoverLayout.defaultSize)
        #expect(MenuBarPopoverLayout.defaultSize.width >= BattleSceneMetrics.expectedPopoverContentWidth)
        #expect(MenuBarPopoverLayout.defaultSize.width <= 660)
        #expect(MenuBarPopoverLayout.defaultSize.height <= 600)
        #expect(MenuBarPopoverLayout.contentMinHeight <= 460)
        #expect(MenuBarPopoverLayout.bottomTabHeight >= 44)
        let battleTabContentHeight = BattleSceneMetrics.compactHeight +
            BattleLogMetrics.panelHeight +
            BattlePanelMetrics.sectionSpacing +
            BattlePanelMetrics.verticalPadding * 2
        #expect(MenuBarPopoverLayout.contentMinHeight >= battleTabContentHeight)
        #expect(MenuBarPopoverLayout.defaultSize.width >= BattleSceneMetrics.expectedPopoverContentWidth + BattlePanelMetrics.horizontalPadding * 2)
        #expect(MenuBarPopoverLayout.minimumScale == MenuBarPopoverLayout.defaultScale)
        #expect(MenuBarPopoverLayout.normalizedScale(0.01) == MenuBarPopoverLayout.minimumScale)
        #expect(MenuBarPopoverLayout.normalizedScale(99) == MenuBarPopoverLayout.maximumScale)
        #expect(minimumSize.width == defaultSize.width)
        #expect(maximumSize.width == defaultSize.width)
        #expect(minimumSize.height == defaultSize.height)
        #expect(maximumSize.height == defaultSize.height)
        #expect(MenuBarPopoverLayout.scaleStep == 0.05)
        #expect(OriginalControlShortcuts.scaleResetFunctionKeyCode == Int(NSF11FunctionKey))
        #expect(OriginalControlShortcuts.scaleResetModifiers == [.shift])
    }

    @Test func completionSettlementOffersDeferAndNextPlaythroughChoices() {
        let progress = ProgressTracker()

        #expect(CompletionSettlementLabels.deferButtonTitle == "稍后开启")
        #expect(CompletionSettlementLabels.deferredConfirmationText.contains("保留结算状态"))
        #expect(CompletionSettlementLabels.retainedProgressText.contains("角色"))
        #expect(CompletionSettlementLabels.retainedProgressText.contains("背包"))
        #expect(CompletionSettlementLabels.title(for: progress) == "一周目通关")
        #expect(CompletionSettlementLabels.startButtonTitle(for: progress) == "开启第 2 周目")
    }
}
