import Testing
import UIKit
@testable import RouteKit

@MainActor
@Suite("Transition")
struct TransitionTests {

  @Test("none transition is recorded as no-op")
  func noneTransition() {
    let coordinator = RecordingCoordinator()

    coordinator.performTransition(.none)

    #expect(coordinator.recorded == [.none])
  }

  @Test("multiple variadic convenience creates correct count")
  func multipleVariadic() {
    let coordinator = RecordingCoordinator()

    coordinator.performTransition(
      .multiple(.push(UIViewController()), .pop(), .dismiss())
    )

    #expect(coordinator.recorded == [.multiple(3), .push, .pop, .dismiss])
  }

  @Test("nested multiple transitions flatten correctly")
  func nestedMultiple() {
    let coordinator = RecordingCoordinator()

    coordinator.performTransition(
      .multiple([
        .push(UIViewController()),
        .multiple([.pop(), .dismiss()]),
      ])
    )

    #expect(coordinator.recorded == [.multiple(2), .push, .multiple(2), .pop, .dismiss])
  }
}
