import Testing
@testable import ForgeObservers

@Suite("KeyboardState")
struct KeyboardStateTests {

    // MARK: - Defaults

    @Test("Hidden static property has isVisible false")
    func hiddenIsNotVisible() {
        #expect(KeyboardState.hidden.isVisible == false)
    }

    @Test("Hidden static property has height zero")
    func hiddenHeightIsZero() {
        #expect(KeyboardState.hidden.height == 0)
    }

    @Test("Hidden static property has animationDuration 0.25")
    func hiddenAnimationDuration() {
        #expect(KeyboardState.hidden.animationDuration == 0.25)
    }

    // MARK: - Equatable

    @Test("Equatable conformance - equal instances")
    func equatableEqual() {
        let a = KeyboardState.hidden
        let b = KeyboardState.hidden
        #expect(a == b)
    }

    @Test("Equatable conformance - different instances")
    func equatableDifferent() {
        let visible = KeyboardState(isVisible: true, height: 300, animationDuration: 0.25)
        #expect(visible != KeyboardState.hidden)
    }

    // MARK: - Initialization

    @Test("Custom initialization stores values correctly")
    func customInit() {
        let state = KeyboardState(isVisible: true, height: 346, animationDuration: 0.3)
        #expect(state.isVisible == true)
        #expect(state.height == 346)
        #expect(state.animationDuration == 0.3)
    }

    @Test("Conforms to Sendable")
    func conformsToSendable() {
        let state: any Sendable = KeyboardState.hidden
        #expect(state is KeyboardState)
    }
}
