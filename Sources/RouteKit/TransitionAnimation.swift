import UIKit

@MainActor
public final class TransitionAnimation {

  public let presentationAnimator: any UIViewControllerAnimatedTransitioning
  public let dismissalAnimator: (any UIViewControllerAnimatedTransitioning)?

  public init(
    presentation: any UIViewControllerAnimatedTransitioning,
    dismissal: (any UIViewControllerAnimatedTransitioning)? = nil
  ) {
    self.presentationAnimator = presentation
    self.dismissalAnimator = dismissal
  }
}
