import Foundation
import RxSwift

final class PostDetailsViewModel {
    let post: Post
    private let repo: PostRepositoryProtocol
    private let disposeBag = DisposeBag()

    
    let comments = BehaviorSubject<[Comment]>(value: [])
    let isLoading = BehaviorSubject<Bool>(value: false)
    let error = PublishSubject<Error>()

    init(post: Post, repo: PostRepositoryProtocol) {
        self.post = post
        self.repo = repo
    }

    func loadComments() {
        isLoading.onNext(true)
        repo.fetchComments(forPostId: post.id)
            .subscribe(
                onNext: { [weak self] comments in
                    self?.comments.onNext(comments)
                    self?.isLoading.onNext(false)
                },
                onError: { [weak self] err in
                    self?.error.onNext(err)
                    self?.isLoading.onNext(false)
                }
            )
            .disposed(by: disposeBag)
    }
}
