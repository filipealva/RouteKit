import RouteKit
import UIKit

indirect enum TestRoute: Route {
  case pushScreen
  case presentModal
  case dismiss
  case popBack
  case popToRoot
  case setRoot
  case chainedRoute(TestRoute)
  case noOp
}

enum TabRoute: Route {
  case selectFirst
  case selectSecond
}

enum WindowRoute: Route {
  case showAuth
  case showMain
}
