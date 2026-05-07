import UIKit

@MainActor
public enum Transition<RouteType: Route> {
  case push(UIViewController, animation: TransitionAnimation? = nil)
  case pop(animation: TransitionAnimation? = nil)
  case popToRoot(animated: Bool = true)
  case present(UIViewController, animated: Bool = true)
  case dismiss(animated: Bool = true)
  case setRoot(UIViewController, animated: Bool = true)
  case route(RouteType)
  case multiple([Transition<RouteType>])
  case none
}

extension Transition {

  public static func multiple(_ transitions: Transition<RouteType>...) -> Transition<RouteType> {
    .multiple(transitions)
  }
}
