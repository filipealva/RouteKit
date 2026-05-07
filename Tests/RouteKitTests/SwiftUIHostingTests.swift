import Testing
import SwiftUI
import UIKit
@testable import RouteKit

@MainActor
@Suite("SwiftUIHosting")
struct SwiftUIHostingTests {

  @Test("hostingController creates a UIHostingController with intrinsic content sizing")
  func hostingControllerCreation() {
    let view = Text("Hello")
    let controller = hostingController(for: view)

    #expect(controller is UIHostingController<Text>)
    #expect(controller.sizingOptions.contains(.intrinsicContentSize))
  }
}
