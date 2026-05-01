
import UIKit
let storyboard = UIStoryboard(name: "Main", bundle: nil)

final class AppCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let postRepository: PostRepositoryProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        self.postRepository = PostRepository(
            networkService: NetworkService(),
            databaseService: DatabaseService()
        )
    }
    
    func start() {
        if SessionManager.shared.isLoggedIn {
            showMain()
        } else {
            showLogin()
        }
    }
    
    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.onLoginSuccess = { [weak self] in
            self?.removeChildCoordinator(loginCoordinator)
            self?.showMain()
        }
        addChildCoordinator(loginCoordinator)
        loginCoordinator.start()
    }
    private func makeTabBarController() -> UITabBarController {
        
        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        ) as? UITabBarController else {
            fatalError("TabBarController not found in storyboard")
        }
        
        return tabBarController
    }
    
    private func showMain() {
        let mainCoordinator = MainTabCoordinator(navigationController: navigationController,tabBarController: makeTabBarController(),
                                                 repository: postRepository)
        mainCoordinator.onLogout = { [weak self] in
            self?.removeChildCoordinator(mainCoordinator)
            self?.showLogin()
        }
        addChildCoordinator(mainCoordinator)
        mainCoordinator.start()
    }
}

