import Testing
import UIKit
@testable import RouteKit

@MainActor
@Suite("Coordinator")
struct CoordinatorTests {

  // MARK: - Child Lifecycle

  @Test("addChild retains the child coordinator")
  func addChild() {
    let coordinator = RecordingCoordinator()
    let child = RecordingCoordinator()

    coordinator.addChild(child)

    #expect(coordinator.children.count == 1)
    #expect(coordinator.children.first === child)
  }

  @Test("removeChild removes by identity")
  func removeChild() {
    let coordinator = RecordingCoordinator()
    let child1 = RecordingCoordinator()
    let child2 = RecordingCoordinator()

    coordinator.addChild(child1)
    coordinator.addChild(child2)
    coordinator.removeChild(child1)

    #expect(coordinator.children.count == 1)
    #expect(coordinator.children.first === child2)
  }

  @Test("removeChild with unknown coordinator is a no-op")
  func removeUnknownChild() {
    let coordinator = RecordingCoordinator()
    let child = RecordingCoordinator()
    let unknown = RecordingCoordinator()

    coordinator.addChild(child)
    coordinator.removeChild(unknown)

    #expect(coordinator.children.count == 1)
  }

  @Test("removeAllChildren empties the children array")
  func removeAllChildren() {
    let coordinator = RecordingCoordinator()
    coordinator.addChild(RecordingCoordinator())
    coordinator.addChild(RecordingCoordinator())
    coordinator.addChild(RecordingCoordinator())

    coordinator.removeAllChildren()

    #expect(coordinator.children.isEmpty)
  }

  // MARK: - Route Dispatch

  @Test("trigger dispatches through prepareTransition and performTransition")
  func triggerRoute() {
    let coordinator = RecordingCoordinator()

    coordinator.trigger(.pushScreen)

    #expect(coordinator.recorded == [.push])
  }

  @Test("none route produces a none transition")
  func noneRoute() {
    let coordinator = RecordingCoordinator()

    coordinator.trigger(.noOp)

    #expect(coordinator.recorded == [.none])
  }

  @Test("chained route re-enters dispatch")
  func chainedRoute() {
    let coordinator = RecordingCoordinator()

    coordinator.trigger(.chainedRoute(.pushScreen))

    #expect(coordinator.recorded == [.route, .push])
  }

  // MARK: - Multiple Transitions

  @Test("multiple transition composes sub-transitions")
  func multipleTransitions() {
    let coordinator = RecordingCoordinator()

    coordinator.performTransition(.multiple(.push(UIViewController()), .pop()))

    #expect(coordinator.recorded == [.multiple(2), .push, .pop])
  }

  // MARK: - Router

  @Test("router triggers routes on the coordinator")
  func routerTrigger() {
    let coordinator = RecordingCoordinator()
    let router = coordinator.router

    router.trigger(.pushScreen)

    #expect(coordinator.recorded == [.push])
  }
}
