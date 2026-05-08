// Demonstrates: Router in ViewModel (MVVM pattern) -- clean separation from Coordinator

import Foundation
import RouteKit

@MainActor
final class HomeViewModel {

  private let router: Router<HomeRoute>

  /// Callback for deep-link requests that cross coordinator boundaries.
  var onDeepLink: ((String) -> Void)?

  let items: [String] = [
    "Getting Started",
    "NavigationCoordinator",
    "TabBarCoordinator",
    "WindowCoordinator",
    "Custom Animations",
    "SwiftUI Hosting",
    "Router Pattern",
  ]

  init(router: Router<HomeRoute>) {
    self.router = router
  }

  // MARK: - Actions

  func selectItem(at index: Int) {
    let title = items[index]
    router.trigger(.detail(title: title))
  }

  func openSettings() {
    router.trigger(.settings)
  }

  func triggerDeepLink() {
    onDeepLink?("Deep Linked Item")
  }
}
