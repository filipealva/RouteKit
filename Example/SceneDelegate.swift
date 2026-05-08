// Demonstrates: Creating the WindowCoordinator as the app's root coordinator

import UIKit
import RouteKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private var appCoordinator: AppCoordinator?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    let coordinator = AppCoordinator(window: window)
    self.appCoordinator = coordinator
    coordinator.start()
  }
}
