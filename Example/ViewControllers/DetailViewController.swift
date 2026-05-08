// Demonstrates: A pushed detail screen (NavigationCoordinator push transition)

import UIKit

@MainActor
final class DetailViewController: UIViewController {

  private let itemTitle: String

  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init(itemTitle: String) {
    self.itemTitle = itemTitle
    super.init(nibName: nil, bundle: nil)
    title = itemTitle
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = itemTitle
    titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    titleLabel.textColor = .label
    titleLabel.textAlignment = .center

    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.text = "This screen was pushed via NavigationCoordinator.\n\nTap the back button or swipe back to trigger didPopViewController in the coordinator."
    descriptionLabel.font = .preferredFont(forTextStyle: .body)
    descriptionLabel.textColor = .secondaryLabel
    descriptionLabel.textAlignment = .center
    descriptionLabel.numberOfLines = 0

    let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 16
    stack.alignment = .center
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }
}
