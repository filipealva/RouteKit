import Testing
import UIKit
@testable import RouteKit

@MainActor
final class TestTabBarCoordinator: TabBarCoordinator<TabRoute> {

  override func prepareTransition(for route: TabRoute) -> Transition<TabRoute> {
    switch route {
    case .selectFirst:
      selectTab(at: 0)
      return .none
    case .selectSecond:
      selectTab(at: 1)
      return .none
    }
  }
}

@MainActor
@Suite("TabBarCoordinator")
struct TabBarCoordinatorTests {

  @Test("init creates a UITabBarController as root")
  func initDefault() {
    let coordinator = TestTabBarCoordinator()

    #expect(coordinator.rootViewController is UITabBarController)
    #expect(coordinator.tabBarController === coordinator.rootViewController)
  }

  @Test("setTabCoordinators syncs children and tab bar view controllers")
  func setTabCoordinators() {
    let coordinator = TestTabBarCoordinator()
    let child1 = RecordingCoordinator()
    let child2 = RecordingCoordinator()

    coordinator.setTabCoordinators([child1, child2])

    #expect(coordinator.children.count == 2)
    #expect(coordinator.tabBarController.viewControllers?.count == 2)
    #expect(coordinator.children[0] === child1)
    #expect(coordinator.children[1] === child2)
  }

  @Test("setTabCoordinators replaces previous children")
  func replaceTabCoordinators() {
    let coordinator = TestTabBarCoordinator()
    let old = RecordingCoordinator()
    let new1 = RecordingCoordinator()
    let new2 = RecordingCoordinator()

    coordinator.setTabCoordinators([old])
    coordinator.setTabCoordinators([new1, new2])

    #expect(coordinator.children.count == 2)
    #expect(coordinator.children.contains { $0 === old } == false)
  }

  @Test("selectTab by index sets selectedIndex")
  func selectTabByIndex() {
    let coordinator = TestTabBarCoordinator()
    coordinator.setTabCoordinators([RecordingCoordinator(), RecordingCoordinator()])

    coordinator.selectTab(at: 1)

    #expect(coordinator.tabBarController.selectedIndex == 1)
  }

  @Test("selectTab by coordinator finds correct index")
  func selectTabByCoordinator() {
    let coordinator = TestTabBarCoordinator()
    let first = RecordingCoordinator()
    let second = RecordingCoordinator()
    coordinator.setTabCoordinators([first, second])

    coordinator.selectTab(for: second)

    #expect(coordinator.tabBarController.selectedIndex == 1)
  }

  @Test("selectTab by unknown coordinator is a no-op")
  func selectTabByUnknown() {
    let coordinator = TestTabBarCoordinator()
    coordinator.setTabCoordinators([RecordingCoordinator()])

    coordinator.selectTab(for: RecordingCoordinator())

    #expect(coordinator.tabBarController.selectedIndex == 0)
  }

  @Test("configureTabs gives access to the tab bar controller")
  func configureTabs() {
    let coordinator = TestTabBarCoordinator()
    var receivedController: UITabBarController?

    coordinator.configureTabs { controller in
      receivedController = controller
    }

    #expect(receivedController === coordinator.tabBarController)
  }
}
