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
}
