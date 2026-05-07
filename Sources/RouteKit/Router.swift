import UIKit

@MainActor
public struct Router<RouteType: Route> {

  private let _trigger: (RouteType) -> Void

  public init(trigger: @escaping (RouteType) -> Void) {
    self._trigger = trigger
  }

  public func trigger(_ route: RouteType) {
    _trigger(route)
  }
}
