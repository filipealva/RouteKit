// Demonstrates: NavigationCoordinator with custom TransitionAnimation

import UIKit
import RouteKit

enum ExploreRoute: Route {
  case list
  case detail(title: String)
}

@MainActor
final class ExploreCoordinator: NavigationCoordinator<ExploreRoute> {

  private let slideAnimation = TransitionAnimation(
    presentation: SlideFromBottomAnimator(isPresenting: true),
    dismissal: SlideFromBottomAnimator(isPresenting: false)
  )

  // MARK: - Start

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "Explore",
      image: UIImage(systemName: "safari"),
      selectedImage: UIImage(systemName: "safari.fill")
    )
    trigger(.list)
  }

  // MARK: - Transitions

  override func prepareTransition(for route: ExploreRoute) -> Transition<ExploreRoute> {
    switch route {
    case .list:
      let exploreVC = ExploreViewController()
      exploreVC.onItemSelected = { [weak self] title in
        self?.router.trigger(.detail(title: title))
      }
      return .push(exploreVC)

    case .detail(let title):
      let detailVC = ExploreDetailViewController(itemTitle: title)
      return .push(detailVC, animation: slideAnimation)
    }
  }

  // MARK: - Public (for deep linking)

  func pushDetail(title: String) {
    trigger(.detail(title: title))
  }
}
