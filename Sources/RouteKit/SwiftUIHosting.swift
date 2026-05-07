import SwiftUI

@MainActor
public func hostingController<Content: View>(
  for view: Content
) -> UIHostingController<Content> {
  let controller = UIHostingController(rootView: view)
  controller.sizingOptions = .intrinsicContentSize
  return controller
}
