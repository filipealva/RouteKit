// Demonstrates: Simple login screen used with WindowCoordinator root switching

import UIKit

@MainActor
final class LoginViewController: UIViewController {

  var onLoginTapped: (() -> Void)?

  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let loginButton = UIButton(type: .system)

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "RouteKit Demo"
    titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
    titleLabel.textColor = .label
    titleLabel.textAlignment = .center

    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.text = "A coordinator-based navigation framework"
    subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.textAlignment = .center

    loginButton.translatesAutoresizingMaskIntoConstraints = false
    loginButton.setTitle("Login", for: .normal)
    loginButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    loginButton.configuration = .filled()
    loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, loginButton])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 16
    stack.alignment = .center
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      loginButton.widthAnchor.constraint(equalToConstant: 200),
      loginButton.heightAnchor.constraint(equalToConstant: 50),
    ])
  }

  @objc private func loginTapped() {
    onLoginTapped?()
  }
}
