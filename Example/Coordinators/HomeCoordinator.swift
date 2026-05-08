// Demonstrates: NavigationCoordinator, push/pop/present, Router in ViewModel,
//   didPopViewController, didDismissModalViewController, child coordinator lifecycle

import UIKit
import RouteKit

enum HomeRoute: Route {
  case list
  case detail(title: String)
  case settings
}

@MainActor
final class HomeCoordinator: NavigationCoordinator<HomeRoute> {

  /// Callback for deep-link requests that need to go through the parent coordinator.
  var onDeepLink: ((String) -> Void)?

  private var settingsChild: (any AnyCoordinator)?

  // MARK: - Start

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "Home",
      image: UIImage(systemName: "house"),
      selectedImage: UIImage(systemName: "house.fill")
    )
    trigger(.list)
  }

  // MARK: - Transitions

  override func prepareTransition(for route: HomeRoute) -> Transition<HomeRoute> {
    switch route {
    case .list:
      let viewModel = HomeViewModel(router: router)
      viewModel.onDeepLink = { [weak self] title in
        self?.onDeepLink?(title)
      }
      let listVC = HomeListViewController(viewModel: viewModel)
      return .push(listVC)

    case .detail(let title):
      let detailVC = DetailViewController(itemTitle: title)
      return .push(detailVC)

    case .settings:
      let settingsVC = SettingsViewController()
      settingsVC.onDone = { [weak self] in
        self?.dismissSettings()
      }
      let nav = UINavigationController(rootViewController: settingsVC)
      nav.modalPresentationStyle = .pageSheet

      // Track as a child so we can clean up on dismiss
      let childCoordinator = SettingsChildCoordinator(navigationController: nav)
      addChild(childCoordinator)
      settingsChild = childCoordinator

      return .present(nav, animated: true)
    }
  }

  // MARK: - Settings Dismiss

  private func dismissSettings() {
    navigationController.dismiss(animated: true) { [weak self] in
      guard let self, let child = self.settingsChild else { return }
      self.removeChild(child)
      self.settingsChild = nil
      print("[HomeCoordinator] Settings dismissed via Done button, child removed")
    }
  }

  // MARK: - Pop Detection

  override func didPopViewController(_ viewController: UIViewController) {
    // Clean up resources when user taps back or swipes to go back
    if viewController is DetailViewController {
      print("[HomeCoordinator] Detail view controller was popped")
    }
  }

  // MARK: - Modal Dismiss Detection

  override func didDismissModalViewController(_ viewController: UIViewController) {
    // Called when user swipes to dismiss the modal
    if let child = settingsChild {
      removeChild(child)
      settingsChild = nil
      print("[HomeCoordinator] Settings dismissed via swipe, child removed")
    }
  }
}

/// A trivial child coordinator used to demonstrate addChild / removeChild lifecycle.
@MainActor
private final class SettingsChildCoordinator: NavigationCoordinator<SettingsRoute> {}

private enum SettingsRoute: Route {}
