import Testing
import UIKit
@testable import RouteKit

@MainActor
@Suite("NavigationCoordinator")
struct NavigationCoordinatorTests {

  @Test("init creates a UINavigationController as root")
  func initDefault() {
    let coordinator = TestNavigationCoordinator()

    #expect(coordinator.rootViewController is UINavigationController)
    #expect(coordinator.navigationController === coordinator.rootViewController)
  }

  @Test("init accepts an existing UINavigationController")
  func initWithExisting() {
    let nav = UINavigationController()
    let coordinator = TestNavigationCoordinator(navigationController: nav)

    #expect(coordinator.navigationController === nav)
  }

  @Test("push transition pushes onto the navigation controller")
  func pushTransition() {
    let coordinator = TestNavigationCoordinator()
    let vc = UIViewController()

    coordinator.performTransition(.push(vc))

    #expect(coordinator.navigationController.viewControllers.contains(vc))
  }

  @Test("multiple pushes stack view controllers")
  func multiplePushes() {
    let coordinator = TestNavigationCoordinator()
    let vc1 = UIViewController()
    let vc2 = UIViewController()

    coordinator.performTransition(.push(vc1))
    coordinator.performTransition(.push(vc2))

    #expect(coordinator.navigationController.viewControllers.count == 2)
  }

  // MARK: - Pop Detection
  //
  // The sequence contract for an animated transition is: `willShow` fires first (transition
  // coordinator present), then the coordinator's completion, then `didShow` — in either
  // completion/didShow order. These tests drive that contract directly and pin the observable
  // outcome (which VCs got `didPopViewController`), never `didShow`'s argument identity, which is
  // unreliable on a cancelled interactive pop.

  /// Builds a coordinator whose stack is `[root, pushed]` with `pushed` tracked, ready to model a
  /// transition off the top.
  private func makePushedCoordinator() -> (
    coordinator: TestNavigationCoordinator,
    nav: FakeTransitionNavigationController,
    root: UIViewController,
    pushed: UIViewController
  ) {
    let root = UIViewController()
    let nav = FakeTransitionNavigationController(rootViewController: root)
    let coordinator = TestNavigationCoordinator(navigationController: nav)
    let pushed = UIViewController()
    coordinator.performTransition(.push(pushed))
    return (coordinator, nav, root, pushed)
  }

  @Test("committed animated pop, didShow before completion, fires one pop")
  func committedAnimatedPopDidShowThenCompletion() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()
    let fake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = fake

    // Transition begins: willShow arms the completion and suppresses this window's didShow.
    nav.delegate?.navigationController?(nav, willShow: root, animated: true)

    // Committed: the stack settles without `pushed`; didShow arrives before the completion.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)
    #expect(coordinator.poppedViewControllers.isEmpty)

    // Completion (not cancelled) reconciles the settled stack → exactly one pop.
    fake.complete(cancelled: false)
    nav.fakeTransitionCoordinator = nil

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("committed animated pop, completion before didShow, fires one pop (idempotent)")
  func committedAnimatedPopCompletionThenDidShow() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()
    let fake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = fake

    nav.delegate?.navigationController?(nav, willShow: root, animated: true)

    // Committed and settled, then the completion runs before didShow.
    nav.setViewControllers([root], animated: false)
    fake.complete(cancelled: false)
    #expect(coordinator.poppedViewControllers.count == 1)

    // The trailing didShow must not double-fire the pop.
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)
    nav.fakeTransitionCoordinator = nil

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("cancelled interactive pop delivering the destination VC fires no pop; a later real pop fires once")
  func cancelledPopDeliveringDestinationVCFiresNoPop() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()
    let fake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = fake

    nav.delegate?.navigationController?(nav, willShow: root, animated: true)

    // The round-2 reality: didShow delivers the transition's *destination* VC (`root`) while the
    // stack transiently reads the popped `[root]` — indistinguishable from a committed pop here.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)

    // Only the coordinator knows it cancelled: the completion skips, so nothing pops.
    fake.complete(cancelled: true)
    nav.setViewControllers([root, pushed], animated: false)
    nav.fakeTransitionCoordinator = nil
    #expect(coordinator.poppedViewControllers.isEmpty)

    // Tracking survived: a subsequent real (non-animated) pop still fires exactly once.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, willShow: root, animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("cancelled interactive pop delivering the restored VC fires no pop")
  func cancelledPopDeliveringRestoredVCFiresNoPop() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()
    let fake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = fake

    nav.delegate?.navigationController?(nav, willShow: root, animated: true)

    // The 1.0.3-assumed shape: didShow delivers the *restored* VC (`pushed`) on a transient
    // popped stack. The fix ignores didShow's argument, so this must behave identically.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: pushed, animated: true)

    fake.complete(cancelled: true)
    nav.setViewControllers([root, pushed], animated: false)
    nav.fakeTransitionCoordinator = nil

    #expect(coordinator.poppedViewControllers.isEmpty)
  }

  @Test("cancelled pop, completion before didShow, fires no pop")
  func cancelledPopCompletionThenDidShow() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()
    let fake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = fake

    nav.delegate?.navigationController?(nav, willShow: root, animated: true)

    // Transient popped stack; the cancelled completion runs before didShow.
    nav.setViewControllers([root], animated: false)
    fake.complete(cancelled: true)
    #expect(coordinator.poppedViewControllers.isEmpty)

    // The trailing didShow (still on the transient stack) is suppressed, so still no pop.
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)
    nav.setViewControllers([root, pushed], animated: false)
    nav.fakeTransitionCoordinator = nil

    #expect(coordinator.poppedViewControllers.isEmpty)
  }

  @Test("non-animated pop reconciles in didShow and fires one pop")
  func nonAnimatedPopFiresOnePop() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()

    // No coordinator: the stack settles synchronously and didShow does the reconciliation.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, willShow: root, animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("stale suppression from a cancelled pop with no didShow self-heals on the next real pop")
  func staleSuppressionSelfHeals() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()
    let fake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = fake

    // Cancelled animated pop that never emits didShow: the suppression flag is left armed.
    nav.delegate?.navigationController?(nav, willShow: root, animated: true)
    fake.complete(cancelled: true)
    nav.fakeTransitionCoordinator = nil
    #expect(coordinator.poppedViewControllers.isEmpty)

    // A real non-animated pop: its coordinator-less willShow clears the stale flag, so didShow
    // reconciles and the pop fires.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, willShow: root, animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("a duplicate didShow after a cancelled pop cannot reconcile the transient stack")
  func duplicateDidShowAfterCancelledPopFiresNoPop() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()
    let fake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = fake

    nav.delegate?.navigationController?(nav, willShow: root, animated: true)

    // Cancelled: the completion skips, the first didShow consumes the suppression flag — and a
    // hypothetical second didShow, still on the transient popped stack, must be ignored too
    // (didShow handles at most one callout per willShow).
    nav.setViewControllers([root], animated: false)
    fake.complete(cancelled: true)
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)
    nav.setViewControllers([root, pushed], animated: false)
    nav.fakeTransitionCoordinator = nil
    #expect(coordinator.poppedViewControllers.isEmpty)

    // Tracking survived: a later real pop still fires exactly once.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, willShow: root, animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)
    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("cancel then commit fires exactly one pop total")
  func cancelThenCommitFiresOnePop() {
    let (coordinator, nav, root, pushed) = makePushedCoordinator()

    // Phase 1 — cancelled animated pop.
    let cancelledFake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = cancelledFake
    nav.delegate?.navigationController?(nav, willShow: root, animated: true)
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)
    cancelledFake.complete(cancelled: true)
    nav.setViewControllers([root, pushed], animated: false)
    #expect(coordinator.poppedViewControllers.isEmpty)

    // Phase 2 — committed animated pop.
    let committedFake = FakeTransitionCoordinator()
    nav.fakeTransitionCoordinator = committedFake
    nav.delegate?.navigationController?(nav, willShow: root, animated: true)
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: true)
    committedFake.complete(cancelled: false)
    nav.fakeTransitionCoordinator = nil

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }
}
