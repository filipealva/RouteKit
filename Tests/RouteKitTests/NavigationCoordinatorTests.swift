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

  @Test("didShow for the shown VC while it is transiently absent (cancelled pop) fires no pop")
  func testDidShowWithViewControllerStillPresentDoesNotFirePop() {
    let root = UIViewController()
    let nav = UINavigationController(rootViewController: root)
    let coordinator = TestNavigationCoordinator(navigationController: nav)
    let pushed = UIViewController()
    coordinator.performTransition(.push(pushed))

    // Mid-cancellation transient: the live stack momentarily reads as popped while the VC
    // being restored is exactly the one didShow reports.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: pushed, animated: false)
    #expect(coordinator.poppedViewControllers.isEmpty)

    // `pushed` must still be tracked: a subsequent real pop (shown VC now `root`) fires once.
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)
    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("didShow after the VC leaves the stack (committed pop) fires pop exactly once")
  func testDidShowAfterRemovalFiresPopOnce() {
    let root = UIViewController()
    let nav = UINavigationController(rootViewController: root)
    let coordinator = TestNavigationCoordinator(navigationController: nav)
    let pushed = UIViewController()
    coordinator.performTransition(.push(pushed))

    // Committed pop: `pushed` is gone and the shown VC is the one beneath it.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("a cancelled transient then a committed pop fires pop exactly once")
  func testCancelThenCommitFiresPopExactlyOnce() {
    let root = UIViewController()
    let nav = UINavigationController(rootViewController: root)
    let coordinator = TestNavigationCoordinator(navigationController: nav)
    let pushed = UIViewController()
    coordinator.performTransition(.push(pushed))

    // Cancel: the transient popped stack with `pushed` as the shown (restoring) VC.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: pushed, animated: false)
    #expect(coordinator.poppedViewControllers.isEmpty)

    // UIKit finishes the cancel, restoring the stack.
    nav.setViewControllers([root, pushed], animated: false)

    // Commit: a real pop now settles the stack without `pushed`.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }
}
