import UIKit
import RxSwift
import RxCocoa

final class PostDetailViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let headerView = UIView()
    private let userAvatarView = UIView()
    private let userAvatarLabel = UILabel()
    private let userNameLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let postTitleLabel = UILabel()
    private let postBodyLabel = UILabel()

    private let viewModel: PostDetailViewModel
    private let disposeBag = DisposeBag()
    private var comments: [Comment] = []

    weak var coordinator: PostsCoordinator?

    init(viewModel: PostDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.loadComments()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.title = "Post Detail"
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)

    }
    private func setupUI() {
        view.backgroundColor = AppTheme.background
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = AppTheme.background
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        tableView.register(
            UINib(nibName: CommentsCell.nibName, bundle: nil),
            forCellReuseIdentifier: CommentsCell.identifier
        )

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        setupHeader()
    }

    private func setupHeader() {
        headerView.backgroundColor = AppTheme.background

        [userAvatarView, userNameLabel, favoriteButton, postTitleLabel, postBodyLabel]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                headerView.addSubview($0)
            }

        userAvatarView.backgroundColor = AppTheme.accent
        userAvatarView.layer.cornerRadius = 24
        userAvatarView.clipsToBounds = true

        userAvatarLabel.translatesAutoresizingMaskIntoConstraints = false
        userAvatarLabel.font = .boldSystemFont(ofSize: 18)
        userAvatarLabel.textColor = .white
        userAvatarLabel.textAlignment = .center
        userAvatarView.addSubview(userAvatarLabel)

        userNameLabel.font = .boldSystemFont(ofSize: 16)

        favoriteButton.tintColor = .systemPink
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

        postTitleLabel.font = .boldSystemFont(ofSize: 18)
        postTitleLabel.numberOfLines = 0

        postBodyLabel.font = .systemFont(ofSize: 16)
        postBodyLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            userAvatarView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            userAvatarView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            userAvatarView.widthAnchor.constraint(equalToConstant: 48),
            userAvatarView.heightAnchor.constraint(equalToConstant: 48),

            userAvatarLabel.centerXAnchor.constraint(equalTo: userAvatarView.centerXAnchor),
            userAvatarLabel.centerYAnchor.constraint(equalTo: userAvatarView.centerYAnchor),

            favoriteButton.centerYAnchor.constraint(equalTo: userAvatarView.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),

            userNameLabel.topAnchor.constraint(equalTo: userAvatarView.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatarView.trailingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),

            postTitleLabel.topAnchor.constraint(equalTo: userAvatarView.bottomAnchor, constant: 16),
            postTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            postTitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),

            postBodyLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 8),
            postBodyLabel.leadingAnchor.constraint(equalTo: postTitleLabel.leadingAnchor),
            postBodyLabel.trailingAnchor.constraint(equalTo: postTitleLabel.trailingAnchor),
            postBodyLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])

        tableView.tableHeaderView = headerView

        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true

        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame.size.height = height
        tableView.tableHeaderView = headerView
    }

    private func bind() {
        viewModel.post
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.updateUI($0) })
            .disposed(by: disposeBag)

        viewModel.comments
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.comments = $0
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                $0 ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)

        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.showError($0) })
            .disposed(by: disposeBag)
    }

    private func updateUI(_ post: Post) {
        userAvatarLabel.text = "U\(post.userId)"
        userNameLabel.text = "User \(post.userId)"
        postTitleLabel.text = post.title.capitalized
        postBodyLabel.text = post.body

        let image = post.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton.setImage(image, for: .normal)

        updateHeaderHeight()
    }

    private func updateHeaderHeight() {
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame.size.height = height
        tableView.tableHeaderView = headerView
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func favoriteTapped() {
        UIView.animate(withDuration: 0.15, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.favoriteButton.transform = .identity
            }
        }
        viewModel.toggleFavorite()
    }
}

extension PostDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CommentsCell.identifier,
            for: indexPath
        ) as? CommentsCell else {
            return UITableViewCell()
        }

        cell.configure(with: comments[indexPath.row])
        return cell
    }
}

extension PostDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !comments.isEmpty else { return nil }

        let container = UIView()
        container.backgroundColor = AppTheme.background

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Comments"
        label.font = .boldSystemFont(ofSize: 18)

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])

        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        comments.isEmpty ? 0 : UITableView.automaticDimension
    }
}
