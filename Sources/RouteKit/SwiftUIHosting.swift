import SwiftUI

@MainActor
public func hostingController<Content: View>(
  for view: Content,
  configure: ((UIHostingController<Content>) -> Void)? = nil
) -> UIHostingController<Content> {
  let controller = UIHostingController(rootView: view)
  controller.sizingOptions = .intrinsicContentSize
  configure?(controller)
  return controller
}
