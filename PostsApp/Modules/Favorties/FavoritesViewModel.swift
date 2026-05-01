import Foundation
import RxSwift
import RxCocoa

final class FavoritesViewModel {
    
    let favorites: BehaviorRelay<[Post]> = BehaviorRelay(value: [])
    let error: PublishSubject<String> = PublishSubject()
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private let repository: PostRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    init(repository: PostRepositoryProtocol) {
        self.repository = repository
        loadFavorites()
    }
    
    func loadFavorites() {
        repository.observeFavorites()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.favorites.accept(posts)
            })
            .disposed(by: disposeBag)
    }
    
    func removeFavorite(postId: Int) {
        repository.removeFavorite(postId: postId)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onError: { [weak self] error in
                    self?.error.onNext("Failed to remove favorite: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
}

