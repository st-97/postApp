//
//  FavoritesCoordinator.swift
//  PostsApp
//
//  Created by Shaikh Taha on 01/05/2026.
//
import UIKit
final class FavoritesCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    private let repository: PostRepositoryProtocol
    var childCoordinators: [Coordinator] = []
    var onPostSelected: ((Post) -> Void)?

    init(navigationController: UINavigationController,
         repository: PostRepositoryProtocol) {
        self.navigationController = navigationController
        self.repository = repository
    }
    
    func start() {
        let viewModel = FavoritesViewModel(repository: repository)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
        viewController.viewModel = viewModel
        viewController.title = "Favorites"
        
        viewController.onPostSelected = { [weak self] post in
            self?.onPostSelected?(post)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
 
}
