import UIKit
import RxSwift
import RxCocoa
import UIKit
import RxSwift
import RxCocoa



final class PostsViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    var viewModel: PostsViewModel!
    private let disposeBag = DisposeBag()

    var onPostSelected: ((Post) -> Void)?
    var onLogoutTapped: (() -> Void)?

    private var dataSource: UITableViewDiffableDataSource<Int, Int>!
    private var previousPosts: [Post] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)


    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupDataSource()
        setupNav()
        setupLoader()
        bind()
        viewModel.loadPosts()
    }
    private func setupLoader() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    private func setupTable() {
        let nib = UINib(nibName: PostTableViewCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, Int>(
            tableView: tableView
        ) { [weak self] tableView, indexPath, postId in

            guard
                let self,
                let post = self.viewModel.posts.value.first(where: { $0.id == postId }),
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: PostTableViewCell.identifier,
                    for: indexPath
                ) as? PostTableViewCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: post)

            cell.onFavoriteTapped = { [weak self] in
                self?.viewModel.toggleFavorite(post: post)
            }

            return cell
        }
        tableView.dataSource = dataSource
    }

    private func setupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }

    private func bind() {
        viewModel.posts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.applySnapshot(posts: posts)
            })
            .disposed(by: disposeBag)
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
 
    private func applySnapshot(posts: [Post]) {
        var snapshot = dataSource.snapshot()
        
        if snapshot.itemIdentifiers.isEmpty {
             
            snapshot.deleteAllItems()
            snapshot.appendSections([0])
            snapshot.appendItems(posts.map(\.id), toSection: 0)
        } else {
            let existingIds = Set(snapshot.itemIdentifiers)
            
            
            let newIds = posts.map(\.id).filter { !existingIds.contains($0) }
            if !newIds.isEmpty {
                snapshot.appendItems(newIds, toSection: 0)
            }
            
            
            let currentIds = Set(posts.map(\.id))
            let removedIds = existingIds.subtracting(currentIds)
            if !removedIds.isEmpty {
                snapshot.deleteItems(Array(removedIds))
            }
            
            
            let changedIds = posts.filter { post in
                previousPosts.first(where: { $0.id == post.id })?.isFavorite != post.isFavorite
            }
            .map(\.id)
            .filter { existingIds.contains($0) }
            
            if !changedIds.isEmpty {
                snapshot.reloadItems(changedIds)
            }
        }
        
        previousPosts = posts
        dataSource.apply(snapshot, animatingDifferences: true)
    }
//    private func applySnapshot(posts: [Post]) {
//        print("applySnapshot called with \(posts.count) posts")
//        
//        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
//        snapshot.appendSections([0])
//        snapshot.appendItems(posts.map(\.id))
//        
//        print("Snapshot items: \(snapshot.itemIdentifiers)")
//        
//        dataSource.apply(snapshot, animatingDifferences: false)  // disable animation for debugging
//        previousPosts = posts
//        
//        print("Snapshot applied. Table rows: \(tableView.numberOfRows(inSection: 0))")
//    }
    @objc private func logoutTapped() {
        onLogoutTapped?()
    }
}

extension PostsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let postId = dataSource.itemIdentifier(for: indexPath),
            let post = viewModel.posts.value.first(where: { $0.id == postId })
        else { return }

        tableView.deselectRow(at: indexPath, animated: true)
        onPostSelected?(post)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
