import Testing
import UIKit
@testable import RouteKit

private final class FakeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval { 0.3 }
  func animateTransition(using ctx: UIViewControllerContextTransitioning) {}
}

@MainActor
@Suite("TransitionAnimation")
struct TransitionAnimationTests {

  @Test("stores presentation animator")
  func presentationAnimator() {
    let animator = FakeAnimator()
    let animation = TransitionAnimation(presentation: animator)

    #expect(animation.presentationAnimator === animator)
  }

  @Test("stores dismissal animator when provided")
  func dismissalAnimator() {
    let presenter = FakeAnimator()
    let dismisser = FakeAnimator()
    let animation = TransitionAnimation(presentation: presenter, dismissal: dismisser)

    #expect(animation.dismissalAnimator === dismisser)
  }

  @Test("dismissal animator defaults to nil")
  func dismissalDefaultsNil() {
    let animation = TransitionAnimation(presentation: FakeAnimator())

    #expect(animation.dismissalAnimator == nil)
  }
}
