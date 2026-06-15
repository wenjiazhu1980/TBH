import Testing
@testable import TBH

@Suite struct ControlsTests {
    @Test func popoverScaleResetAndClampStayDeterministic() {
        let defaultSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.defaultScale)
        let minimumSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.minimumScale)
        let maximumSize = MenuBarPopoverLayout.size(for: MenuBarPopoverLayout.maximumScale)

        #expect(defaultSize == MenuBarPopoverLayout.defaultSize)
        #expect(MenuBarPopoverLayout.normalizedScale(0.01) == MenuBarPopoverLayout.minimumScale)
        #expect(MenuBarPopoverLayout.normalizedScale(99) == MenuBarPopoverLayout.maximumScale)
        #expect(minimumSize.width < defaultSize.width)
        #expect(maximumSize.width > defaultSize.width)
        #expect(minimumSize.height < defaultSize.height)
        #expect(maximumSize.height > defaultSize.height)
        #expect(MenuBarPopoverLayout.scaleStep == 0.05)
    }
}
