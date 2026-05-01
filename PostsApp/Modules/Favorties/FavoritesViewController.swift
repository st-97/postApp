import UIKit
import RxSwift
import RxCocoa
final class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FavoritesViewModel!
    private let disposeBag = DisposeBag()
    
    var onPostSelected: ((Post) -> Void)?
    
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

    private func bind() {
        
        viewModel.favorites
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                guard let self else { return }

                self.emptyLabel.isHidden = !posts.isEmpty
                self.tableView.isHidden = posts.isEmpty
            })
            .disposed(by: disposeBag)

        viewModel.favorites
            .bind(to: tableView.rx.items(
                cellIdentifier: PostTableViewCell.identifier,
                cellType: PostTableViewCell.self
            )) { [weak self] _, post, cell in
                
                cell.configure(with: post)
                
                cell.onFavoriteTapped = { [weak self] in
                    self?.viewModel.removeFavorite(postId: post.id)
                }
                
            }
            .disposed(by: disposeBag)
    }
}
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.favorites.value.count else { return }

        let post = viewModel.favorites.value[indexPath.row]
        onPostSelected?(post)
    }
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        
        let posts = viewModel.favorites.value
        guard indexPath.row < posts.count else { return }
        
        let post = posts[indexPath.row]
        viewModel.removeFavorite(postId: post.id)
    }
}
