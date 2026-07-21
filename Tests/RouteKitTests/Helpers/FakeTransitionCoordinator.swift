import UIKit

/// A `UINavigationController` whose `transitionCoordinator` can be forced on or off, letting a
/// test model an animated transition (coordinator present) versus a non-animated one (nil).
@MainActor
final class FakeTransitionNavigationController: UINavigationController {

  var fakeTransitionCoordinator: (any UIViewControllerTransitionCoordinator)?

  override var transitionCoordinator: (any UIViewControllerTransitionCoordinator)? {
    fakeTransitionCoordinator ?? super.transitionCoordinator
  }
}

/// A hand-driven transition coordinator. Records the completions handed to
/// `animate(alongsideTransition:completion:)` and replays them on demand via `complete(cancelled:)`,
/// passing itself as the context so `isCancelled` reads the value the test chose.
@MainActor
final class FakeTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {

  private(set) var isCancelled: Bool = false
  private var completions: [(any UIViewControllerTransitionCoordinatorContext) -> Void] = []

  /// Settles `isCancelled`, then fires every recorded completion with `self` as the context.
  func complete(cancelled: Bool) {
    isCancelled = cancelled
    let pending = completions
    completions.removeAll()
    for completion in pending {
      completion(self)
    }
  }

  // MARK: - UIViewControllerTransitionCoordinator

  func animate(
    alongsideTransition animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?,
    completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)? = nil
  ) -> Bool {
    if let completion { completions.append(completion) }
    return true
  }

  func animateAlongsideTransition(
    in view: UIView?,
    animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?,
    completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)? = nil
  ) -> Bool {
    if let completion { completions.append(completion) }
    return true
  }

  func notifyWhenInteractionEnds(
    _ handler: @escaping (any UIViewControllerTransitionCoordinatorContext) -> Void
  ) {}

  func notifyWhenInteractionChanges(
    _ handler: @escaping (any UIViewControllerTransitionCoordinatorContext) -> Void
  ) {}

  // MARK: - UIViewControllerTransitionCoordinatorContext

  var isAnimated: Bool { true }
  var presentationStyle: UIModalPresentationStyle { .none }
  var initiallyInteractive: Bool { true }
  var isInterruptible: Bool { false }
  var isInteractive: Bool { true }
  var transitionDuration: TimeInterval { 0 }
  var percentComplete: CGFloat { 0 }
  var completionVelocity: CGFloat { 0 }
  var completionCurve: UIView.AnimationCurve { .linear }
  var containerView: UIView { UIView() }
  var targetTransform: CGAffineTransform { .identity }

  func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? { nil }
  func view(forKey key: UITransitionContextViewKey) -> UIView? { nil }
}
