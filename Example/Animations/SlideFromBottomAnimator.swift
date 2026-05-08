// Demonstrates: Custom UIViewControllerAnimatedTransitioning for use with TransitionAnimation

import UIKit

final class SlideFromBottomAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  private let isPresenting: Bool

  init(isPresenting: Bool) {
    self.isPresenting = isPresenting
    super.init()
  }

  func transitionDuration(
    using transitionContext: (any UIViewControllerContextTransitioning)?
  ) -> TimeInterval {
    0.4
  }

  func animateTransition(
    using transitionContext: any UIViewControllerContextTransitioning
  ) {
    if isPresenting {
      animatePresentation(using: transitionContext)
    } else {
      animateDismissal(using: transitionContext)
    }
  }

  // MARK: - Presentation

  private func animatePresentation(
    using transitionContext: any UIViewControllerContextTransitioning
  ) {
    guard let toView = transitionContext.view(forKey: .to) else {
      transitionContext.completeTransition(false)
      return
    }

    let container = transitionContext.containerView
    container.addSubview(toView)

    let finalFrame = transitionContext.finalFrame(
      for: transitionContext.viewController(forKey: .to)!
    )
    toView.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)

    let duration = transitionDuration(using: transitionContext)
    UIView.animate(
      withDuration: duration,
      delay: 0,
      usingSpringWithDamping: 0.85,
      initialSpringVelocity: 0.5,
      options: .curveEaseInOut
    ) {
      toView.frame = finalFrame
    } completion: { finished in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }

  // MARK: - Dismissal

  private func animateDismissal(
    using transitionContext: any UIViewControllerContextTransitioning
  ) {
    guard let fromView = transitionContext.view(forKey: .from) else {
      transitionContext.completeTransition(false)
      return
    }

    let duration = transitionDuration(using: transitionContext)
    let targetY = fromView.frame.origin.y + fromView.frame.height

    UIView.animate(
      withDuration: duration,
      delay: 0,
      options: .curveEaseIn
    ) {
      fromView.frame.origin.y = targetY
    } completion: { finished in
      fromView.removeFromSuperview()
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }
}
