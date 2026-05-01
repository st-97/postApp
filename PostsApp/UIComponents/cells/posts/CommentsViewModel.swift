import Foundation
import RxSwift
import RxCocoa

final class CommentsViewModel {
    let comments: BehaviorRelay<[Comment]> = BehaviorRelay(value: [])
    let error: PublishSubject<String> = PublishSubject()
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private let repository: PostRepositoryProtocol
    private let disposeBag = DisposeBag()
    private let postId: Int

    init(repository: PostRepositoryProtocol, postId: Int) {
        self.repository = repository
        self.postId = postId
        loadComments()
    }

    func loadComments() {
        isLoading.accept(true)
        repository.fetchComments(forPostId: postId)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] comments in
                    self?.comments.accept(comments)
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    self?.error.onNext(error.localizedDescription)
                    self?.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
}
