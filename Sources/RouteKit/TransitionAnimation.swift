import UIKit

@MainActor
public final class TransitionAnimation: @unchecked Sendable {

  nonisolated(unsafe) public let presentationAnimator: any UIViewControllerAnimatedTransitioning
  nonisolated(unsafe) public let dismissalAnimator: (any UIViewControllerAnimatedTransitioning)?

  public init(
    presentation: any UIViewControllerAnimatedTransitioning,
    dismissal: (any UIViewControllerAnimatedTransitioning)? = nil
  ) {
    self.presentationAnimator = presentation
    self.dismissalAnimator = dismissal
  }
}
