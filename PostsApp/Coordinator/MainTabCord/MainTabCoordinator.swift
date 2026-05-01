import UIKit
 
final class MainTabCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    private let tabBarController: UITabBarController
    var onShowPostDetail: ((Post) -> Void)?
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    
    private let repository: PostRepositoryProtocol

    init(navigationController: UINavigationController,
         tabBarController: UITabBarController,
         repository: PostRepositoryProtocol) {
        
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        self.repository = repository
    }
    
    func start() {
        
        guard let viewControllers = tabBarController.viewControllers,
              viewControllers.count >= 2,
              let postsNav = viewControllers[0] as? UINavigationController,
              let favoritesNav = viewControllers[1] as? UINavigationController
        else {
            fatalError("TabBarController not configured correctly in storyboard")
        }
        
        // MARK: - Posts Coordinator
        let postsCoordinator = PostsCoordinator(
            navigationController: postsNav,
            repository: repository
        )
        
        postsCoordinator.onLogoutTapped = { [weak self] in
            self?.showLogout()
        }
        postsCoordinator.onPostSelected = { [weak self] post in
            self?.showPostDetail(post: post)
        }
        addChildCoordinator(postsCoordinator)
        postsCoordinator.start()
        
        
        let favoritesCoordinator = FavoritesCoordinator(
            navigationController: favoritesNav,
            repository: repository
        )
 
        favoritesCoordinator.onPostSelected = { [weak self] post in
            print("Post selected: \(post)")
            self?.showPostDetail(post: post)
        }
        addChildCoordinator(favoritesCoordinator)
        favoritesCoordinator.start()
        
        
        
        tabBarController.tabBar.tintColor = AppTheme.accent
        tabBarController.tabBar.backgroundColor = AppTheme.surface
        tabBarController.tabBar.unselectedItemTintColor = AppTheme.textSecondary
        
        
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    private func showLogout() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            SessionManager.shared.clearSession()
            self?.onLogout?()
        })
        
        tabBarController.present(alert, animated: true)
    }
    private func showPostDetail(post: Post) {
        let viewModel = PostDetailViewModel(post: post, repository: repository)
        let viewController = PostDetailViewController(viewModel: viewModel)
        
 
        navigationController.pushViewController(viewController, animated: true)
    }
}
