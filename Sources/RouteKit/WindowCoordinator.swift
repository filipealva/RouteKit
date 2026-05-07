import UIKit

@MainActor
open class WindowCoordinator<RouteType: Route>: Coordinator<RouteType> {

  public let window: UIWindow

  public private(set) var activeChild: (any AnyCoordinator)?

  public init(window: UIWindow) {
    self.window = window
    super.init(rootViewController: UIViewController())
  }

  open override func performTransition(_ transition: Transition<RouteType>) {
    switch transition {
    case .setRoot(let vc, let animated):
      setRootViewController(vc, animated: animated)
    default:
      super.performTransition(transition)
    }
  }

  public func switchTo(_ coordinator: any AnyCoordinator, animated: Bool = true) {
    activeChild = coordinator
    if !children.contains(where: { $0 === coordinator }) {
      addChild(coordinator)
    }
    setRootViewController(coordinator.rootViewController, animated: animated)
  }

  private func setRootViewController(_ viewController: UIViewController, animated: Bool) {
    window.rootViewController = viewController
    if animated {
      UIView.transition(
        with: window,
        duration: 0.3,
        options: .transitionCrossDissolve,
        animations: nil
      )
    }
    window.makeKeyAndVisible()
  }
}
