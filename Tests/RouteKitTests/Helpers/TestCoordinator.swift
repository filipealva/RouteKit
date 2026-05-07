import RouteKit
import UIKit

@MainActor
final class RecordingCoordinator: Coordinator<TestRoute> {

  enum RecordedTransition: Equatable {
    case push
    case pop
    case popToRoot
    case present
    case dismiss
    case setRoot
    case route
    case multiple(Int)
    case none
  }

  var recorded: [RecordedTransition] = []

  init() {
    super.init(rootViewController: UIViewController())
  }

  override func prepareTransition(for route: TestRoute) -> Transition<TestRoute> {
    switch route {
    case .pushScreen:
      return .push(UIViewController())
    case .presentModal:
      return .present(UIViewController())
    case .dismiss:
      return .dismiss()
    case .popBack:
      return .pop()
    case .popToRoot:
      return .popToRoot()
    case .setRoot:
      return .setRoot(UIViewController())
    case .chainedRoute(let inner):
      return .route(inner)
    case .noOp:
      return .none
    }
  }

  override func performTransition(_ transition: Transition<TestRoute>) {
    switch transition {
    case .push:
      recorded.append(.push)
    case .pop:
      recorded.append(.pop)
    case .popToRoot:
      recorded.append(.popToRoot)
    case .present:
      recorded.append(.present)
    case .dismiss:
      recorded.append(.dismiss)
    case .setRoot:
      recorded.append(.setRoot)
    case .route:
      recorded.append(.route)
      super.performTransition(transition)
    case .multiple(let transitions):
      recorded.append(.multiple(transitions.count))
      for t in transitions { performTransition(t) }
    case .none:
      recorded.append(.none)
    }
  }
}

@MainActor
final class TestNavigationCoordinator: NavigationCoordinator<TestRoute> {

  var poppedViewControllers: [UIViewController] = []

  override func prepareTransition(for route: TestRoute) -> Transition<TestRoute> {
    switch route {
    case .pushScreen:
      return .push(UIViewController())
    case .popBack:
      return .pop()
    case .popToRoot:
      return .popToRoot()
    case .presentModal:
      return .present(UIViewController())
    case .dismiss:
      return .dismiss()
    default:
      return .none
    }
  }

  override func didPopViewController(_ viewController: UIViewController) {
    poppedViewControllers.append(viewController)
  }
}
