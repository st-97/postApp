import Foundation
import RxSwift
import RxCocoa
final class PostsViewModel {

    let posts = BehaviorRelay<[Post]>(value: [])
    let error = PublishSubject<String>()
    let isLoading = BehaviorRelay<Bool>(value: false)

    private let repository: PostRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(repository: PostRepositoryProtocol) {
        self.repository = repository
        observePosts()
    }

    private func observePosts() {
        repository.observePosts()
            .observe(on: MainScheduler.instance)
            .bind(to: posts)
            .disposed(by: disposeBag)
    }

    func loadPosts() {
        guard !isLoading.value else { return }
        isLoading.accept(true)
 
        repository.syncPosts()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak self] in
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    self?.error.onNext(error.localizedDescription)
                    self?.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }

    func toggleFavorite(post: Post) {
        repository.toggleFavorite(postId: post.id)
            .subscribe(onCompleted: { [weak self] in
                guard let self else { return }

                var current = self.posts.value

                if let index = current.firstIndex(where: { $0.id == post.id }) {
                    current[index].isFavorite.toggle()
                }

                self.posts.accept(current)
            })
            .disposed(by: disposeBag)
    }
    func removeFavorite(postId: Int) {
        repository.removeFavorite(postId: postId)
            .subscribe(onError: { [weak self] error in
                self?.error.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

//    private func observePosts() {
//        repository.observePosts()
//            .observe(on: MainScheduler.instance)
//            .bind(to: posts)
//            .disposed(by: disposeBag)
//    }
}
