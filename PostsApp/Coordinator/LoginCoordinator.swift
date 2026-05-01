import UIKit

 
final class LoginCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onLoginSuccess: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let loginViewController = storyboard
            .instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        else {
            return
        }
        
        let viewModel = LoginViewModel()
        viewModel.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
        
        loginViewController.viewModel = viewModel
        
        navigationController.setViewControllers([loginViewController], animated: false)
    }
}
