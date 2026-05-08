// Demonstrates: WindowCoordinator, root switching with setRoot / switchTo, cross-dissolve animation

import UIKit
import RouteKit

enum AppRoute: Route {
  case login
  case main
}

@MainActor
final class AppCoordinator: WindowCoordinator<AppRoute> {

  // MARK: - Start

  func start() {
    trigger(.login)
  }

  // MARK: - Transitions

  override func prepareTransition(for route: AppRoute) -> Transition<AppRoute> {
    switch route {
    case .login:
      let loginVC = LoginViewController()
      loginVC.onLoginTapped = { [weak self] in
        self?.router.trigger(.main)
      }
      return .setRoot(loginVC, animated: true)

    case .main:
      let tabCoordinator = MainTabCoordinator()
      tabCoordinator.start()
      switchTo(tabCoordinator, animated: true)
      return .none
    }
  }
}
