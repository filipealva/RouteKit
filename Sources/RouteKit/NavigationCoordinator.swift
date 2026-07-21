@preconcurrency import UIKit

@MainActor
open class NavigationCoordinator<RouteType: Route>: Coordinator<RouteType> {

  public var navigationController: UINavigationController {
    rootViewController as! UINavigationController
  }

  private var activeAnimation: TransitionAnimation?
  private var trackedViewControllers: [UIViewController] = []
  private var navigationDelegate: NavigationDelegate?

  private var suppressNextDidShowReconcile = false
  private var didHandleDidShow = false

  public init(navigationController: UINavigationController = UINavigationController()) {
    super.init(rootViewController: navigationController)
    let delegate = NavigationDelegate()
    delegate.onWillShow = { [weak self] _ in self?.handleWillShow() }
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

  /// Arms pop reconciliation for the transition that is beginning.
  ///
  /// Pops are inferred by diffing `trackedViewControllers` against the live nav stack. The only
  /// hard problem is a *cancelled* interactive pop: UIKit fires `didShow` mid-cancellation while
  /// `viewControllers` transiently reads the popped stack, which looks exactly like a committed
  /// pop. `didShow`'s argument is not a reliable disambiguator either — on iOS 26 a cancelled
  /// interactive pop delivers the transition's *destination* VC (the root below), so its callout
  /// (`didShow(root)` with a transient `[root]` stack) is byte-for-byte identical to a committed
  /// pop's. No synchronous, `didShow`-based diff can tell the two apart.
  ///
  /// The transition coordinator's `context.isCancelled` is the only authoritative signal. So for
  /// an animated transition we defer reconciliation to the coordinator's completion and gate it
  /// on `!context.isCancelled`: by then the stack has settled for every non-cancelled outcome
  /// (committed pop, push, restore-after-cancel that still commits nothing), and a cancelled pop
  /// simply skips. `didShow` is suppressed for that window so it cannot reconcile off the
  /// transient stack. Coordinator-less (non-animated) transitions have no completion to hook, so
  /// they reconcile in `didShow` against the already-settled stack. A `willShow` with no
  /// coordinator also clears any flag stranded by a cancelled transition that never emitted
  /// `didShow`. Reconciliation is a pure diff, so it is idempotent and self-healing: a callout
  /// missed by one path is caught by the next.
  ///
  /// `didShow` additionally handles at most one callout per `willShow`: the 1:1 pairing is only
  /// convention, and a hypothetical second `didShow` for a cancelled transition would arrive
  /// after the suppression flag was consumed, free to reconcile off the still-transient stack.
  private func handleWillShow() {
    didHandleDidShow = false
    guard let coordinator = navigationController.transitionCoordinator else {
      suppressNextDidShowReconcile = false
      return
    }
    suppressNextDidShowReconcile = true
    coordinator.animate(alongsideTransition: nil) { [weak self] context in
      guard let self, !context.isCancelled else { return }
      self.reconcileTrackedViewControllers()
    }
  }

  private func handleDidShow() {
    guard !didHandleDidShow else { return }
    didHandleDidShow = true
    if suppressNextDidShowReconcile {
      suppressNextDidShowReconcile = false
      return
    }
    reconcileTrackedViewControllers()
  }

  private func reconcileTrackedViewControllers() {
    let currentVCs = Set(navigationController.viewControllers.map(ObjectIdentifier.init))
    let popped = trackedViewControllers.filter { !currentVCs.contains(ObjectIdentifier($0)) }
    guard !popped.isEmpty else { return }
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

@MainActor
private final class NavigationDelegate: NSObject, UINavigationControllerDelegate {

  var onWillShow: ((UIViewController) -> Void)?
  var onDidShow: (() -> Void)?
  var onAnimationController: (
    (UINavigationController.Operation) -> (any UIViewControllerAnimatedTransitioning)?
  )?

  nonisolated func navigationController(
    _ navigationController: UINavigationController,
    willShow viewController: UIViewController,
    animated: Bool
  ) {
    MainActor.assumeIsolated {
      onWillShow?(viewController)
    }
  }

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
