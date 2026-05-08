// Demonstrates: UITableView driven by HomeViewModel, Router triggers from ViewModel

import UIKit

@MainActor
final class HomeListViewController: UITableViewController {

  private let viewModel: HomeViewModel

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(style: .insetGrouped)
    title = "Home"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "gearshape"),
      style: .plain,
      target: self,
      action: #selector(settingsTapped)
    )
  }

  // MARK: - UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "Features"
    case 1: return "Deep Linking"
    default: return nil
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return viewModel.items.count
    case 1: return 1
    default: return 0
    }
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    switch indexPath.section {
    case 0:
      var config = cell.defaultContentConfiguration()
      config.text = viewModel.items[indexPath.row]
      config.image = UIImage(systemName: "chevron.right.circle")
      cell.contentConfiguration = config
      cell.accessoryType = .disclosureIndicator

    case 1:
      var config = cell.defaultContentConfiguration()
      config.text = "Deep Link to Explore Detail"
      config.image = UIImage(systemName: "link")
      config.textProperties.color = .systemBlue
      cell.contentConfiguration = config
      cell.accessoryType = .none

    default:
      break
    }

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    switch indexPath.section {
    case 0:
      viewModel.selectItem(at: indexPath.row)
    case 1:
      viewModel.triggerDeepLink()
    default:
      break
    }
  }

  // MARK: - Actions

  @objc private func settingsTapped() {
    viewModel.openSettings()
  }
}
