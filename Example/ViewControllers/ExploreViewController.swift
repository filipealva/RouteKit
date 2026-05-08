// Demonstrates: Explore list that triggers custom transition animations

import UIKit

@MainActor
final class ExploreViewController: UIViewController {

  var onItemSelected: ((String) -> Void)?

  private let items = [
    "Mountain Peaks",
    "Ocean Depths",
    "City Lights",
    "Forest Trails",
    "Desert Dunes",
  ]

  private let tableView = UITableView(frame: .zero, style: .insetGrouped)

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  init() {
    super.init(nibName: nil, bundle: nil)
    title = "Explore"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    "Tap an item (custom slide-from-bottom animation)"
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    var config = cell.defaultContentConfiguration()
    config.text = items[indexPath.row]
    config.image = UIImage(systemName: "photo")
    cell.contentConfiguration = config
    cell.accessoryType = .disclosureIndicator
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    onItemSelected?(items[indexPath.row])
  }
}
