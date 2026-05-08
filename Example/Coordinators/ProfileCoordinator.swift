// Demonstrates: NavigationCoordinator, hostingController for SwiftUI views

import UIKit
import SwiftUI
import RouteKit

enum ProfileRoute: Route {
  case root
  case detail(name: String)
}

@MainActor
final class ProfileCoordinator: NavigationCoordinator<ProfileRoute> {

  // MARK: - Start

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "Profile",
      image: UIImage(systemName: "person"),
      selectedImage: UIImage(systemName: "person.fill")
    )
    trigger(.root)
  }

  // MARK: - Transitions

  override func prepareTransition(for route: ProfileRoute) -> Transition<ProfileRoute> {
    switch route {
    case .root:
      let rootVC = ProfileRootViewController()
      rootVC.onShowDetail = { [weak self] name in
        self?.router.trigger(.detail(name: name))
      }
      return .push(rootVC)

    case .detail(let name):
      let swiftUIView = ProfileDetailView(name: name)
      let vc = hostingController(for: swiftUIView) { hosting in
        hosting.title = name
        hosting.modalPresentationStyle = .fullScreen
      }
      return .push(vc)
    }
  }
}

// MARK: - Profile Root ViewController

/// Simple root screen for the Profile tab.
@MainActor
final class ProfileRootViewController: UIViewController {

  var onShowDetail: ((String) -> Void)?

  private let nameLabel = UILabel()
  private let showDetailButton = UIButton(type: .system)

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init() {
    super.init(nibName: nil, bundle: nil)
    title = "Profile"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.text = "Welcome to your Profile"
    nameLabel.font = .preferredFont(forTextStyle: .title2)
    nameLabel.textColor = .label
    nameLabel.textAlignment = .center

    showDetailButton.translatesAutoresizingMaskIntoConstraints = false
    showDetailButton.setTitle("View Profile Detail (SwiftUI)", for: .normal)
    showDetailButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
    showDetailButton.addTarget(self, action: #selector(detailTapped), for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [nameLabel, showDetailButton])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 24
    stack.alignment = .center
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  @objc private func detailTapped() {
    onShowDetail?("Jane Appleseed")
  }
}
