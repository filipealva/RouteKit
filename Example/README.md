# RouteKit Example App

A complete iOS demo app that showcases every feature of RouteKit.

## Features Demonstrated

- [x] **WindowCoordinator** -- root view controller switching with cross-dissolve animation
- [x] **TabBarCoordinator** -- tab management with 3 tabs (Home, Explore, Profile)
- [x] **NavigationCoordinator** -- push, pop, pop-to-root, and modal presentation
- [x] **Router in ViewModels** -- MVVM pattern with clean ViewModel/Coordinator separation
- [x] **Modal presentation + dismiss detection** -- `didDismissModalViewController` for swipe-to-dismiss
- [x] **Pop detection** -- `didPopViewController` for back-button/swipe-back cleanup
- [x] **SwiftUI views via hostingController** -- SwiftUI + UIKit interop
- [x] **Custom transition animations** -- `TransitionAnimation` with custom `UIViewControllerAnimatedTransitioning`
- [x] **Deep linking** -- chained routes across coordinators (switch tab + push detail)
- [x] **Transition.multiple** -- composing multiple transitions
- [x] **Transition.route** -- re-routing from one route to another
- [x] **Child coordinator lifecycle** -- addChild / removeChild

## How to Run

1. Open Xcode and create a new **iOS App** project (Interface: Storyboard, Language: Swift).
2. Delete the auto-generated `ViewController.swift`, `Main.storyboard`, and any SceneDelegate/AppDelegate files.
3. In the project's **Info.plist**, remove the "Main storyboard file base name" key and the `UISceneConfiguration` storyboard name if present.
4. Copy all `.swift` files from this `Example/` directory (including subdirectories) into your Xcode project.
5. In Xcode, go to the project settings > **Package Dependencies** > click **+** > **Add Local...** > select the `RouteKit/` root directory (the parent of this `Example/` folder).
6. In your app target's **Frameworks, Libraries, and Embedded Content**, add `RouteKit`.
7. Set the deployment target to **iOS 18.0** or later.
8. Build and run.

## App Flow

```
Launch
  -> LoginViewController (via AppCoordinator / WindowCoordinator)
  -> Tap "Login"
  -> MainTabCoordinator (TabBarCoordinator) with 3 tabs:

     [Home]                    [Explore]                [Profile]
     HomeCoordinator           ExploreCoordinator       ProfileCoordinator
     NavigationCoordinator     NavigationCoordinator    NavigationCoordinator
       |                        |                        |
       HomeListViewController   ExploreViewController    (root VC)
       (uses HomeViewModel)      |                        |
       |                        ExploreDetailVC           ProfileDetailView
       DetailViewController     (custom slide-from-      (SwiftUI via
       (pushed)                  bottom animation)        hostingController)
       |
       SettingsViewController
       (presented modally)

     Deep Link button on Home -> switches to Explore tab + pushes detail
```

## File Overview

| File | Demonstrates |
|------|-------------|
| `AppDelegate.swift` | Minimal app delegate, window setup |
| `SceneDelegate.swift` | Creates AppCoordinator (WindowCoordinator) |
| `Coordinators/AppCoordinator.swift` | WindowCoordinator, setRoot, switchTo |
| `Coordinators/MainTabCoordinator.swift` | TabBarCoordinator, setTabCoordinators, configureTabs, selectTab |
| `Coordinators/HomeCoordinator.swift` | NavigationCoordinator, push/pop/present, didPopViewController, didDismissModalViewController |
| `Coordinators/ExploreCoordinator.swift` | NavigationCoordinator, custom TransitionAnimation |
| `Coordinators/ProfileCoordinator.swift` | NavigationCoordinator, hostingController for SwiftUI |
| `ViewModels/HomeViewModel.swift` | Router in ViewModel (MVVM pattern) |
| `ViewControllers/LoginViewController.swift` | Simple login UI |
| `ViewControllers/HomeListViewController.swift` | Table view driven by HomeViewModel |
| `ViewControllers/DetailViewController.swift` | Pushed detail screen |
| `ViewControllers/SettingsViewController.swift` | Modally presented settings |
| `ViewControllers/ExploreViewController.swift` | Explore items list |
| `ViewControllers/ExploreDetailViewController.swift` | Custom animation target |
| `SwiftUIViews/ProfileDetailView.swift` | SwiftUI view hosted in UIKit |
| `Animations/SlideFromBottomAnimator.swift` | Custom UIViewControllerAnimatedTransitioning |
