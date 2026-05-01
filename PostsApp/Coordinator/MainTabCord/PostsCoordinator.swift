//
//  PostsCoordinator.swift
//  PostsApp
//
//  Created by Shaikh Taha on 01/05/2026.
//
import UIKit

final class PostsCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let repository: PostRepositoryProtocol
    
    var onLogoutTapped: (() -> Void)?
    var onPostSelected: ((Post) -> Void)?
    
    init(navigationController: UINavigationController,
         repository: PostRepositoryProtocol) {
        self.navigationController = navigationController
        self.repository = repository
    }
    
    func start() {
        let viewModel = PostsViewModel(repository: repository)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "PostsViewController"
        ) as! PostsViewController
        viewController.viewModel = viewModel
        viewController.title = "Posts"
        
        viewController.onPostSelected = { [weak self] post in
            self?.onPostSelected?(post)
        }
        
        viewController.onLogoutTapped = { [weak self] in
            self?.onLogoutTapped?()
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}
