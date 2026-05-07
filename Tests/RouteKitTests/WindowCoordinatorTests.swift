import Testing
import UIKit
@testable import RouteKit

@MainActor
final class TestWindowCoordinator: WindowCoordinator<WindowRoute> {

  override func prepareTransition(for route: WindowRoute) -> Transition<WindowRoute> {
    switch route {
    case .showAuth:
      return .setRoot(UIViewController(), animated: false)
    case .showMain:
      return .setRoot(UIViewController(), animated: false)
    }
  }
}

@MainActor
@Suite("WindowCoordinator")
struct WindowCoordinatorTests {

  @Test("init stores the window")
  func initStoresWindow() {
    let window = UIWindow()
    let coordinator = TestWindowCoordinator(window: window)

    #expect(coordinator.window === window)
  }

  @Test("switchTo sets the active child and adds it to children")
  func switchToSetsActiveChild() {
    let window = UIWindow()
    let coordinator = TestWindowCoordinator(window: window)
    let child = RecordingCoordinator()

    coordinator.switchTo(child, animated: false)

    #expect(coordinator.activeChild === child)
    #expect(coordinator.children.count == 1)
    #expect(coordinator.children.first === child)
  }

  @Test("switchTo sets the window root view controller")
  func switchToSetsRoot() {
    let window = UIWindow()
    let coordinator = TestWindowCoordinator(window: window)
    let child = RecordingCoordinator()

    coordinator.switchTo(child, animated: false)

    #expect(window.rootViewController === child.rootViewController)
  }

  @Test("switchTo does not duplicate child if already present")
  func switchToNoDuplicate() {
    let window = UIWindow()
    let coordinator = TestWindowCoordinator(window: window)
    let child = RecordingCoordinator()

    coordinator.switchTo(child, animated: false)
    coordinator.switchTo(child, animated: false)

    #expect(coordinator.children.count == 1)
  }

  @Test("switchTo between different children updates activeChild")
  func switchBetweenChildren() {
    let window = UIWindow()
    let coordinator = TestWindowCoordinator(window: window)
    let auth = RecordingCoordinator()
    let main = RecordingCoordinator()

    coordinator.switchTo(auth, animated: false)
    coordinator.switchTo(main, animated: false)

    #expect(coordinator.activeChild === main)
    #expect(coordinator.children.count == 2)
    #expect(window.rootViewController === main.rootViewController)
  }

  @Test("setRoot transition sets window root")
  func setRootTransition() {
    let window = UIWindow()
    let coordinator = TestWindowCoordinator(window: window)
    let vc = UIViewController()

    coordinator.performTransition(.setRoot(vc, animated: false))

    #expect(window.rootViewController === vc)
  }
}
