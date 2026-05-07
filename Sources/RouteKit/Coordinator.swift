import UIKit

@MainActor
public protocol AnyCoordinator: AnyObject {
  var rootViewController: UIViewController { get }
}

@MainActor
open class Coordinator<RouteType: Route>: NSObject, AnyCoordinator,
  UIAdaptivePresentationControllerDelegate {

  public let rootViewController: UIViewController

  public private(set) var children: [any AnyCoordinator] = []

  public lazy var router: Router<RouteType> = Router { [weak self] route in
    self?.trigger(route)
  }

  public init(rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    super.init()
  }

  // MARK: - Route Dispatch

  open func prepareTransition(for route: RouteType) -> Transition<RouteType> {
    fatalError("Subclasses must override prepareTransition(for:)")
  }

  public func trigger(_ route: RouteType) {
    let transition = prepareTransition(for: route)
    performTransition(transition)
  }

  open func performTransition(_ transition: Transition<RouteType>) {
    switch transition {
    case .present(let vc, let animated):
      vc.presentationController?.delegate = self
      rootViewController.present(vc, animated: animated)
    case .dismiss(let animated):
      rootViewController.dismiss(animated: animated)
    case .multiple(let transitions):
      for t in transitions { performTransition(t) }
    case .route(let route):
      trigger(route)
    case .none:
      break
    default:
      break
    }
  }

  // MARK: - Child Lifecycle

  public func addChild(_ child: any AnyCoordinator) {
    children.append(child)
  }

  public func removeChild(_ child: any AnyCoordinator) {
    children.removeAll { $0 === child }
  }

  public func removeAllChildren() {
    children.removeAll()
  }

  // MARK: - Modal Dismiss Detection

  open func didDismissModalViewController(_ viewController: UIViewController) {}

  nonisolated public func presentationControllerDidDismiss(
    _ presentationController: UIPresentationController
  ) {
    MainActor.assumeIsolated {
      didDismissModalViewController(presentationController.presentedViewController)
    }
  }
}
