import Testing
import UIKit
@testable import RouteKit

@MainActor
@Suite("Router")
struct RouterTests {

  @Test("Router triggers the correct route")
  func triggerCorrectRoute() {
    var triggeredRoutes: [TestRoute] = []
    let router = Router<TestRoute> { route in
      triggeredRoutes.append(route)
    }

    router.trigger(.pushScreen)
    router.trigger(.dismiss)

    #expect(triggeredRoutes.count == 2)
  }

  @Test("Router with weak coordinator reference does not crash after dealloc")
  func weakReference() {
    var coordinator: RecordingCoordinator? = RecordingCoordinator()
    let router = coordinator!.router

    coordinator = nil

    // Should not crash — weak self is nil, trigger is a no-op
    router.trigger(.pushScreen)
  }

  @Test("Multiple routers from same coordinator all trigger correctly")
  func multipleRouters() {
    let coordinator = RecordingCoordinator()
    let router1 = coordinator.router
    let router2 = coordinator.router

    router1.trigger(.pushScreen)
    router2.trigger(.presentModal)

    #expect(coordinator.recorded == [.push, .present])
  }
}
