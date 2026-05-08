// Demonstrates: Modally presented screen, dismiss detection via didDismissModalViewController

import UIKit

@MainActor
final class SettingsViewController: UIViewController {

  var onDone: (() -> Void)?

  private let titleLabel = UILabel()
  private let infoLabel = UILabel()

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init() {
    super.init(nibName: nil, bundle: nil)
    title = "Settings"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Done",
      style: .done,
      target: self,
      action: #selector(doneTapped)
    )

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Settings"
    titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    titleLabel.textColor = .label
    titleLabel.textAlignment = .center

    infoLabel.translatesAutoresizingMaskIntoConstraints = false
    infoLabel.text = "This screen was presented modally.\n\nTap Done to dismiss programmatically, or swipe down to trigger didDismissModalViewController."
    infoLabel.font = .preferredFont(forTextStyle: .body)
    infoLabel.textColor = .secondaryLabel
    infoLabel.textAlignment = .center
    infoLabel.numberOfLines = 0

    let stack = UIStackView(arrangedSubviews: [titleLabel, infoLabel])
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

  @objc private func doneTapped() {
    dismiss(animated: true)
  }
}
