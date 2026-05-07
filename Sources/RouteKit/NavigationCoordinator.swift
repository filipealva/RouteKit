@preconcurrency import UIKit

@MainActor
open class NavigationCoordinator<RouteType: Route>: Coordinator<RouteType> {

  public var navigationController: UINavigationController {
    rootViewController as! UINavigationController
  }

  private var activeAnimation: TransitionAnimation?
  private var trackedViewControllers: [UIViewController] = []
  private var navigationDelegate: NavigationDelegate?

  public init(navigationController: UINavigationController = UINavigationController()) {
    super.init(rootViewController: navigationController)
    let delegate = NavigationDelegate()
    delegate.onDidShow = { [weak self] in self?.handleDidShow() }
    delegate.onAnimationController = { [weak self] op in self?.animationController(for: op) }
    self.navigationDelegate = delegate
    navigationController.delegate = delegate
  }

  // MARK: - Transition Execution

  open override func performTransition(_ transition: Transition<RouteType>) {
    switch transition {
    case .push(let vc, let animation):
      activeAnimation = animation
      trackedViewControllers.append(vc)
      navigationController.pushViewController(vc, animated: true)

    case .pop(let animation):
      activeAnimation = animation
      navigationController.popViewController(animated: true)

    case .popToRoot(let animated):
      trackedViewControllers.removeAll()
      navigationController.popToRootViewController(animated: animated)

    default:
      super.performTransition(transition)
    }
  }

  // MARK: - Pop Detection

  open func didPopViewController(_ viewController: UIViewController) {}

  private func handleDidShow() {
    let currentVCs = Set(navigationController.viewControllers.map { ObjectIdentifier($0) })
    let popped = trackedViewControllers.filter { !currentVCs.contains(ObjectIdentifier($0)) }
    trackedViewControllers.removeAll { !currentVCs.contains(ObjectIdentifier($0)) }
    for vc in popped {
      didPopViewController(vc)
    }
  }

  private func animationController(
    for operation: UINavigationController.Operation
  ) -> (any UIViewControllerAnimatedTransitioning)? {
    switch operation {
    case .push:
      let animator = activeAnimation?.presentationAnimator
      activeAnimation = nil
      return animator
    case .pop:
      return activeAnimation?.dismissalAnimator
    default:
      return nil
    }
  }
}

// MARK: - Navigation Delegate

private final class NavigationDelegate: NSObject, UINavigationControllerDelegate {

  nonisolated(unsafe) var onDidShow: (() -> Void)?
  nonisolated(unsafe) var onAnimationController: (
    (UINavigationController.Operation) -> (any UIViewControllerAnimatedTransitioning)?
  )?

  nonisolated func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    MainActor.assumeIsolated {
      onDidShow?()
    }
  }

  nonisolated func navigationController(
    _ navigationController: UINavigationController,
    animationControllerFor operation: UINavigationController.Operation,
    from fromVC: UIViewController,
    to toVC: UIViewController
  ) -> (any UIViewControllerAnimatedTransitioning)? {
    MainActor.assumeIsolated {
      onAnimationController?(operation)
    }
  }
}
