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

  @Test("didShow with the tracked VC still on the stack (cancelled pop) fires no pop")
  func testDidShowWithViewControllerStillPresentDoesNotFirePop() async {
    let root = UIViewController()
    let nav = UINavigationController(rootViewController: root)
    let coordinator = TestNavigationCoordinator(navigationController: nav)
    let pushed = UIViewController()
    coordinator.performTransition(.push(pushed))

    // Cancelled interactive pop: didShow fires while the stack is still [root, pushed].
    nav.delegate?.navigationController?(nav, didShow: pushed, animated: false)
    await Task.yield()

    #expect(coordinator.poppedViewControllers.isEmpty)
    #expect(nav.viewControllers == [root, pushed])
  }

  @Test("didShow after the VC leaves the stack (committed pop) fires pop exactly once")
  func testDidShowAfterRemovalFiresPopOnce() async {
    let root = UIViewController()
    let nav = UINavigationController(rootViewController: root)
    let coordinator = TestNavigationCoordinator(navigationController: nav)
    let pushed = UIViewController()
    coordinator.performTransition(.push(pushed))

    // Committed pop: the stack has settled without the pushed VC by the time didShow fires.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)
    await Task.yield()

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }

  @Test("a cancelled didShow then a committed didShow fires pop exactly once")
  func testCancelThenCommitFiresPopExactlyOnce() async {
    let root = UIViewController()
    let nav = UINavigationController(rootViewController: root)
    let coordinator = TestNavigationCoordinator(navigationController: nav)
    let pushed = UIViewController()
    coordinator.performTransition(.push(pushed))

    // Cancel: stack still [root, pushed] — tracking must survive intact.
    nav.delegate?.navigationController?(nav, didShow: pushed, animated: false)
    await Task.yield()
    #expect(coordinator.poppedViewControllers.isEmpty)

    // Commit: stack settles to [root] — the surviving tracking fires the pop.
    nav.setViewControllers([root], animated: false)
    nav.delegate?.navigationController?(nav, didShow: root, animated: false)
    await Task.yield()

    #expect(coordinator.poppedViewControllers.count == 1)
    #expect(coordinator.poppedViewControllers.first === pushed)
  }
}
