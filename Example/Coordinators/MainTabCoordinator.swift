// Demonstrates: TabBarCoordinator, setTabCoordinators, configureTabs, selectTab

import UIKit
import RouteKit

enum MainTabRoute: Route {
  case selectHome
  case selectExplore
  case selectProfile
  case deepLinkExploreDetail(title: String)
}

@MainActor
final class MainTabCoordinator: TabBarCoordinator<MainTabRoute> {

  private var homeCoordinator: HomeCoordinator?
  private var exploreCoordinator: ExploreCoordinator?
  private var profileCoordinator: ProfileCoordinator?

  // MARK: - Start

  func start() {
    let home = HomeCoordinator()
    home.onDeepLink = { [weak self] title in
      self?.router.trigger(.deepLinkExploreDetail(title: title))
    }
    home.start()

    let explore = ExploreCoordinator()
    explore.start()

    let profile = ProfileCoordinator()
    profile.start()

    homeCoordinator = home
    exploreCoordinator = explore
    profileCoordinator = profile

    setTabCoordinators([home, explore, profile])

    configureTabs { tabBar in
      tabBar.tabBar.tintColor = .systemBlue
    }
  }

  // MARK: - Transitions

  override func prepareTransition(for route: MainTabRoute) -> Transition<MainTabRoute> {
    switch route {
    case .selectHome:
      selectTab(at: 0)
      return .none

    case .selectExplore:
      selectTab(at: 1)
      return .none

    case .selectProfile:
      selectTab(at: 2)
      return .none

    case .deepLinkExploreDetail(let title):
      // Deep link: switch to Explore tab, then push a detail screen
      selectTab(at: 1)
      exploreCoordinator?.pushDetail(title: title)
      return .none
    }
  }
}
