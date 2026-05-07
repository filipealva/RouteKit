import UIKit

@MainActor
open class TabBarCoordinator<RouteType: Route>: Coordinator<RouteType> {

  public var tabBarController: UITabBarController {
    rootViewController as! UITabBarController
  }

  public init(tabBarController: UITabBarController = UITabBarController()) {
    super.init(rootViewController: tabBarController)
  }

  public func setTabCoordinators(_ coordinators: [any AnyCoordinator]) {
    removeAllChildren()
    for coordinator in coordinators {
      addChild(coordinator)
    }
    tabBarController.viewControllers = coordinators.map(\.rootViewController)
  }

  public func configureTabs(_ configuration: (UITabBarController) -> Void) {
    configuration(tabBarController)
  }

  public func selectTab(at index: Int) {
    tabBarController.selectedIndex = index
  }

  public func selectTab(for coordinator: any AnyCoordinator) {
    guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
    tabBarController.selectedIndex = index
  }
}
