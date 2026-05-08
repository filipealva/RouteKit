// Demonstrates: Target screen for custom transition animation (slide from bottom)

import UIKit

@MainActor
final class ExploreDetailViewController: UIViewController {

  private let itemTitle: String

  private let imageView = UIImageView()
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

    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(systemName: "photo.artframe")
    imageView.tintColor = .systemBlue
    imageView.contentMode = .scaleAspectFit

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = itemTitle
    titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    titleLabel.textColor = .label
    titleLabel.textAlignment = .center

    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.text = "This screen appeared with a custom slide-from-bottom animation using TransitionAnimation and a custom UIViewControllerAnimatedTransitioning."
    descriptionLabel.font = .preferredFont(forTextStyle: .body)
    descriptionLabel.textColor = .secondaryLabel
    descriptionLabel.textAlignment = .center
    descriptionLabel.numberOfLines = 0

    let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, descriptionLabel])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 20
    stack.alignment = .center
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: 80),
      imageView.heightAnchor.constraint(equalToConstant: 80),
      stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }
}
