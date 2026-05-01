import Foundation
import RxSwift
import RxCocoa

final class PostDetailViewModel {
    
     
    private let _post: BehaviorRelay<Post>
    private let repository: PostRepositoryProtocol
    private let disposeBag = DisposeBag()
    
     
    let post: Observable<Post>
    let comments: BehaviorRelay<[Comment]> = BehaviorRelay(value: [])
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let error: PublishSubject<String> = PublishSubject()
    
    init(post: Post, repository: PostRepositoryProtocol) {
        self._post = BehaviorRelay(value: post)
        self.post = _post.asObservable()
        self.repository = repository
        observeFavoriteChanges()
    }
    
    func loadComments() {
        guard !isLoading.value else { return }
        isLoading.accept(true)
        
        repository.fetchComments(forPostId: _post.value.id)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] comments in
                    self?.comments.accept(comments)
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] err in
                    self?.error.onNext("Failed to load comments: \(err.localizedDescription)")
                    self?.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func toggleFavorite() {
        repository.toggleFavorite(postId: _post.value.id)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onError: { [weak self] error in
                    self?.error.onNext("Failed to toggle favorite: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    private func observeFavoriteChanges() {
        repository.observeFavorites()
            .map { Set($0.map { $0.id }) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] favoriteIds in
                guard let self else { return }

                var post = self._post.value
                post.isFavorite = favoriteIds.contains(post.id)

                self._post.accept(post)
            })
            .disposed(by: disposeBag)
    }
}
