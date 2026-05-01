import UIKit
import RxSwift
import RxCocoa

final class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FavoritesViewModel!
    private let disposeBag = DisposeBag()
    
    var onPostSelected: ((Post) -> Void)?
    
    private var dataSource: UITableViewDiffableDataSource<Int, Int>!
    private var previousFavorites: [Post] = []
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite posts found"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        setupEmptyLabel()
        bind()
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        title = "Favorites"

        tableView.backgroundColor = AppTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150

        let nib = UINib(nibName: PostTableViewCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PostTableViewCell.identifier)
        
        tableView.delegate = self
    }
    
    private func setupEmptyLabel() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, Int>(
            tableView: tableView
        ) { [weak self] tableView, indexPath, postId in

            guard
                let self,
                let post = self.viewModel.favorites.value.first(where: { $0.id == postId }),
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: PostTableViewCell.identifier,
                    for: indexPath
                ) as? PostTableViewCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: post)

            cell.onFavoriteTapped = { [weak self] in
                self?.viewModel.removeFavorite(postId: post.id)
            }

            return cell
        }
        
        tableView.dataSource = dataSource
    }

    private func bind() {
        viewModel.favorites
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.applySnapshot(posts: posts)
                self?.emptyLabel.isHidden = !posts.isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    private func applySnapshot(posts: [Post]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(posts.map(\.id))
        dataSource.apply(snapshot, animatingDifferences: true)
        previousFavorites = posts
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let postId = dataSource.itemIdentifier(for: indexPath),
            let post = viewModel.favorites.value.first(where: { $0.id == postId })
        else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        onPostSelected?(post)
    }
    
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        guard let postId = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            self?.viewModel.removeFavorite(postId: postId)
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
