# RouteKit

A lightweight, Swift 6-ready UIKit coordinator package. Route-based navigation with custom transitions in ~400 lines of code.

## Why RouteKit?

The coordinator pattern is the standard way to manage UIKit navigation, but existing libraries are either abandoned (no Swift 6 support, iOS 18 conflicts) or over-engineered. RouteKit keeps XCoordinator's best idea — route enums dispatched through `prepareTransition(for:)` — and strips everything else down to the essentials.

- **9 files, zero dependencies**
- **Swift 6 strict concurrency** — all types are `@MainActor`
- **iOS 18+** — uses modern UIKit APIs
- **MVVM-friendly** — `Router` decouples ViewModels from coordinators
- **Custom transitions** — plug in any `UIViewControllerAnimatedTransitioning`
- **SwiftUI interop** — host SwiftUI views via `hostingController(for:)`

## Installation

Add RouteKit via Swift Package Manager:

```swift
dependencies: [
  .package(url: "https://github.com/filipealva/RouteKit.git", from: "1.0.0")
]
```

Or in Xcode: File > Add Package Dependencies > paste the repository URL.

## Quick Start

### 1. Define your routes

```swift
import RouteKit

enum HomeRoute: Route {
  case detail(itemId: String)
  case settings
  case profile(userId: UUID)
}
```

### 2. Create a coordinator

```swift
final class HomeCoordinator: NavigationCoordinator<HomeRoute> {

  override func prepareTransition(for route: HomeRoute) -> Transition<HomeRoute> {
    switch route {
    case .detail(let itemId):
      let vc = DetailViewController(itemId: itemId)
      return .push(vc)

    case .settings:
      let vc = SettingsViewController()
      return .present(vc)

    case .profile(let userId):
      let view = ProfileView(userId: userId)
      return .push(hostingController(for: view))
    }
  }
}
```

### 3. Trigger routes

```swift
let coordinator = HomeCoordinator()
coordinator.trigger(.detail(itemId: "abc"))
```

Or from a ViewModel via `Router`:

```swift
final class HomeViewModel {
  private let router: Router<HomeRoute>

  init(router: Router<HomeRoute>) {
    self.router = router
  }

  func settingsTapped() {
    router.trigger(.settings)
  }
}
```

## Core Concepts

### Coordinator Hierarchy

RouteKit provides four coordinator types that form a tree:

```
WindowCoordinator        — owns the UIWindow, switches between major flows
  └── TabBarCoordinator  — owns a UITabBarController, one child per tab
        ├── NavigationCoordinator  — owns a UINavigationController (push/pop)
        ├── NavigationCoordinator
        └── NavigationCoordinator
```

| Type | Backs | Use Case |
|------|-------|----------|
| `Coordinator<R>` | Any `UIViewController` | Base class; subclass for custom containers |
| `NavigationCoordinator<R>` | `UINavigationController` | Push/pop flows within a tab |
| `TabBarCoordinator<R>` | `UITabBarController` | Tab management |
| `WindowCoordinator<R>` | `UIWindow` | App-level root switching (auth/main) |

### Routes

A route is an enum conforming to `Route`. Each case represents a navigation action your coordinator can perform.

```swift
enum AuthRoute: Route {
  case login
  case signup
  case forgotPassword(email: String)
}
```

### Transitions

`Transition<R>` describes what happens when a route is triggered:

| Case | Description |
|------|-------------|
| `.push(vc, animation:)` | Push onto navigation stack |
| `.pop(animation:)` | Pop from navigation stack |
| `.popToRoot(animated:)` | Pop to root of navigation stack |
| `.present(vc, animated:)` | Modal presentation |
| `.dismiss(animated:)` | Dismiss modal |
| `.setRoot(vc, animated:)` | Set window root (WindowCoordinator) |
| `.route(route)` | Re-enter dispatch (deep linking) |
| `.multiple([transitions])` | Compose multiple transitions |
| `.none` | No-op |

### Router

`Router<R>` is a lightweight struct that ViewModels hold to trigger routes without knowing about the coordinator:

```swift
// The coordinator creates its router automatically
let router = coordinator.router

// Pass it to ViewModels
let viewModel = HomeViewModel(router: coordinator.router)
```

The router captures a `[weak self]` reference to the coordinator — no retain cycles, no complexity.

### Child Coordinators

Child lifecycle is **explicit**. You add and remove children manually:

```swift
override func prepareTransition(for route: HomeRoute) -> Transition<HomeRoute> {
  switch route {
  case .settings:
    let settingsCoordinator = SettingsCoordinator()
    addChild(settingsCoordinator)
    return .present(settingsCoordinator.rootViewController)
  }
}
```

## Recipes

### App-Level Root Switching

```swift
enum AppRoute: Route {
  case auth
  case main
}

final class AppCoordinator: WindowCoordinator<AppRoute> {
  private var authCoordinator: AuthCoordinator?
  private var mainCoordinator: MainTabCoordinator?

  override func prepareTransition(for route: AppRoute) -> Transition<AppRoute> {
    switch route {
    case .auth:
      let coordinator = AuthCoordinator()
      authCoordinator = coordinator
      switchTo(coordinator)
      return .none

    case .main:
      let coordinator = MainTabCoordinator()
      mainCoordinator = coordinator
      authCoordinator = nil
      switchTo(coordinator)
      return .none
    }
  }
}

// In SceneDelegate:
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private var appCoordinator: AppCoordinator?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
             options: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    self.window = window

    let coordinator = AppCoordinator(window: window)
    appCoordinator = coordinator
    coordinator.trigger(.auth)
  }
}
```

### Tab Bar with Navigation Coordinators

```swift
enum MainTabRoute: Route {
  case initial
}

final class MainTabCoordinator: TabBarCoordinator<MainTabRoute> {
  private let homeCoordinator = HomeCoordinator()
  private let searchCoordinator = SearchCoordinator()
  private let profileCoordinator = ProfileCoordinator()

  override func prepareTransition(for route: MainTabRoute) -> Transition<MainTabRoute> {
    switch route {
    case .initial:
      setTabCoordinators([homeCoordinator, searchCoordinator, profileCoordinator])

      configureTabs { tabBar in
        tabBar.viewControllers?[0].tabBarItem = UITabBarItem(
          title: "Home", image: UIImage(systemName: "house"), tag: 0
        )
        tabBar.viewControllers?[1].tabBarItem = UITabBarItem(
          title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1
        )
        tabBar.viewControllers?[2].tabBarItem = UITabBarItem(
          title: "Profile", image: UIImage(systemName: "person"), tag: 2
        )
      }

      return .none
    }
  }
}
```

### iOS 18 UITab API

```swift
configureTabs { [weak self] tabBar in
  guard let self else { return }
  let homeTab = UITab(title: "Home", image: UIImage(systemName: "house"),
                      identifier: "home") { _ in
    self.homeCoordinator.rootViewController
  }
  let searchTab = UITab(title: "Search", image: UIImage(systemName: "magnifyingglass"),
                        identifier: "search") { _ in
    self.searchCoordinator.rootViewController
  }
  tabBar.tabs = [homeTab, searchTab]
}
```

### Modal Presentation with Dismiss Detection

```swift
final class HomeCoordinator: NavigationCoordinator<HomeRoute> {
  private var settingsCoordinator: SettingsCoordinator?

  override func prepareTransition(for route: HomeRoute) -> Transition<HomeRoute> {
    switch route {
    case .settings:
      let coordinator = SettingsCoordinator()
      settingsCoordinator = coordinator
      addChild(coordinator)
      let nav = coordinator.navigationController
      nav.modalPresentationStyle = .formSheet
      return .present(nav)
    default:
      return .none
    }
  }

  // Called when the user swipes to dismiss the modal
  override func didDismissModalViewController(_ viewController: UIViewController) {
    if let coordinator = settingsCoordinator {
      removeChild(coordinator)
      settingsCoordinator = nil
    }
  }
}
```

### Back-Button Detection

```swift
final class HomeCoordinator: NavigationCoordinator<HomeRoute> {
  private var detailCoordinator: DetailCoordinator?

  override func didPopViewController(_ viewController: UIViewController) {
    // Clean up any child coordinator associated with the popped VC
    if let coordinator = detailCoordinator,
       coordinator.rootViewController === viewController {
      removeChild(coordinator)
      detailCoordinator = nil
    }
  }
}
```

### SwiftUI Views in Coordinators

```swift
import SwiftUI

override func prepareTransition(for route: HomeRoute) -> Transition<HomeRoute> {
  switch route {
  case .profile(let userId):
    let view = ProfileView(userId: userId)
    return .push(hostingController(for: view))

  case .settings:
    let view = SettingsView()
    let hc = hostingController(for: view) { controller in
      controller.modalPresentationStyle = .formSheet
    }
    return .present(hc)
  }
}
```

### Custom Push/Pop Animations

```swift
final class SlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval { 0.4 }

  func animateTransition(using ctx: UIViewControllerContextTransitioning) {
    guard let toView = ctx.view(forKey: .to) else { return }
    let container = ctx.containerView
    container.addSubview(toView)
    toView.transform = CGAffineTransform(translationX: container.bounds.width, y: 0)
    UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0,
                   usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
      toView.transform = .identity
    } completion: { _ in
      ctx.completeTransition(!ctx.transitionWasCancelled)
    }
  }
}

// Usage:
let animation = TransitionAnimation(presentation: SlideAnimator())
return .push(vc, animation: animation)
```

### Deep Linking

Chain routes through the coordinator tree:

```swift
func handleDeepLink(_ url: URL) {
  guard let route = parseURL(url) else { return }

  switch route {
  case .profile(let userId):
    mainTabCoordinator?.selectTab(at: 2)
    profileCoordinator?.trigger(.userDetail(userId))
  }
}
```

### MVVM Integration

RouteKit's `Router` is designed for MVVM. ViewModels hold a router to trigger navigation without knowing about UIKit:

```swift
// UIKit ViewModel (Combine) — must be @MainActor for Router access under Swift 6
@MainActor
final class ItemListViewModel {
  @Published private(set) var items: [Item] = []
  private let router: Router<HomeRoute>

  init(router: Router<HomeRoute>) {
    self.router = router
  }

  func itemTapped(_ item: Item) {
    router.trigger(.detail(itemId: item.id))
  }
}

// SwiftUI ViewModel (@Observable)
@MainActor @Observable
final class ItemListViewModel {
  var items: [Item] = []
  private let router: Router<HomeRoute>

  init(router: Router<HomeRoute>) {
    self.router = router
  }

  func itemTapped(_ item: Item) {
    router.trigger(.detail(itemId: item.id))
  }
}
```

In the coordinator:

```swift
override func prepareTransition(for route: HomeRoute) -> Transition<HomeRoute> {
  switch route {
  case .initial:
    let viewModel = ItemListViewModel(router: router)
    let vc = ItemListViewController(viewModel: viewModel)
    return .push(vc)
  // ...
  }
}
```

## Migration from XCoordinator

| XCoordinator | RouteKit | Notes |
|-------------|----------|-------|
| `Route` protocol | `Route` protocol | Same concept |
| `BaseCoordinator<R, T>` | `Coordinator<R>` | Single generic parameter |
| `NavigationCoordinator<R>` | `NavigationCoordinator<R>` | Same |
| `TabBarCoordinator<R>` | `TabBarCoordinator<R>` | Same |
| `ViewCoordinator<R>` | `Coordinator<R>` | Use base class directly |
| `NavigationTransition` | `Transition<R>` | Unified transition type |
| `prepareTransition(for:)` | `prepareTransition(for:)` | Same pattern |
| `StrongRouter<R>` | `Router<R>` | Single type, closure-based |
| `WeakRouter<R>` | `Router<R>` | Weak by default (closure captures `[weak self]`) |
| `UnownedRouter<R>` | `Router<R>` | Not needed |
| `Animation` class | `TransitionAnimation` | Simpler wrapper |
| `router.trigger(.route)` | `router.trigger(.route)` | Same API |
| `Presentable` protocol | Not needed | Coordinators own VCs directly |

## Requirements

- iOS 18.0+
- Swift 6.0+
- Xcode 16.0+

## License

RouteKit is available under the MIT license. See [LICENSE](LICENSE) for details.
