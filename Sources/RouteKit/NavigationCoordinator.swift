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
    delegate.onDidShow = { [weak self] shown in self?.handleDidShow(shown: shown) }
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

  /// Reconciles `trackedViewControllers` against the live nav stack and emits
  /// `didPopViewController` for anything that disappeared.
  ///
  /// `shown` is the view controller `didShow` just surfaced. During a *cancelled* interactive
  /// pop, UIKit fires `didShow` for the VC being restored while `viewControllers` transiently
  /// still reflects the popped stack — so a tracked VC can momentarily read as absent even
  /// though it was not popped. That transient is the only situation in which the absent VC is
  /// also the shown VC: a genuinely popped VC is never the one left on screen. Excluding
  /// `shown` from the diff therefore suppresses the spurious pop with a synchronous,
  /// timing-independent invariant (no runloop deferral, no race against UIKit's restore) and
  /// keeps the VC tracked so a later real pop still fires exactly once.
  private func handleDidShow(shown: UIViewController) {
    let currentVCs = Set(navigationController.viewControllers.map { ObjectIdentifier($0) })
    let popped = trackedViewControllers.filter { $0 !== shown && !currentVCs.contains(ObjectIdentifier($0)) }
    trackedViewControllers.removeAll { $0 !== shown && !currentVCs.contains(ObjectIdentifier($0)) }
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

@MainActor
private final class NavigationDelegate: NSObject, UINavigationControllerDelegate {

  var onDidShow: ((UIViewController) -> Void)?
  var onAnimationController: (
    (UINavigationController.Operation) -> (any UIViewControllerAnimatedTransitioning)?
  )?

  nonisolated func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    MainActor.assumeIsolated {
      onDidShow?(viewController)
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
