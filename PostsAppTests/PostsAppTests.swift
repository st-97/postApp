 
import XCTest
import RxSwift
import RxCocoa
@testable import PostsApp
import XCTest
import RxSwift
import RxCocoa
@testable import PostsApp

// MARK: - Mocks

final class MockSessionManager: SessionManagerProtocol {
    var savedEmail: String?
    func saveSession(email: String) { savedEmail = email }
    func clearSession() { savedEmail = nil }
    func getCurrentSession() -> String? { savedEmail }
}

final class MockPostRepository: PostRepositoryProtocol {
    var syncPostsResult: Completable = .empty()
    var observePostsResult: Observable<[Post]> = .just([])
    var toggleFavoriteResult: Completable = .empty()
    var observeFavoritesResult: Observable<[Post]> = .just([])
    
    var toggledPostId: Int?
    
    func syncPosts() -> Completable { syncPostsResult }
    func observePosts() -> Observable<[Post]> { observePostsResult }
    func toggleFavorite(postId: Int) -> Completable {
        toggledPostId = postId
        return toggleFavoriteResult
    }
    func observeFavorites() -> Observable<[Post]> { observeFavoritesResult }
    func removeFavorite(postId: Int) -> Completable { .empty() }
    func fetchComments(forPostId postId: Int) -> Observable<[Comment]> { .just([]) }
    func fetchPosts() -> Observable<[Post]> { .just([]) }
}

// MARK: - Tests

final class LoginValidatorTests: XCTestCase {
    let validator = LoginValidator()
    
    func testValidEmail() {
        XCTAssertTrue(validator.isEmailValid("test@example.com"))
    }
    
    func testInvalidEmail() {
        XCTAssertFalse(validator.isEmailValid("invalid"))
    }
    
    func testValidPassword() {
        XCTAssertTrue(validator.isPasswordValid("password1"))
    }
    
    func testInvalidPasswordTooShort() {
        XCTAssertFalse(validator.isPasswordValid("short"))
    }
}

final class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockSession: MockSessionManager!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        mockSession = MockSessionManager()
        viewModel = LoginViewModel(sessionManager: mockSession, validator: LoginValidator())
        disposeBag = DisposeBag()
    }
    
    func testSubmitDisabledWithInvalidInput() {
        viewModel.emailInput.accept("bad")
        viewModel.passwordInput.accept("bad")
        
        var result: Bool?
        viewModel.isSubmitEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)
        
        XCTAssertEqual(result, false)
    }
    
    func testSubmitEnabledWithValidInput() {
        viewModel.emailInput.accept("test@example.com")
        viewModel.passwordInput.accept("password1")
        
        var result: Bool?
        viewModel.isSubmitEnabled
            .drive(onNext: { result = $0 })
            .disposed(by: disposeBag)
        
        XCTAssertEqual(result, true)
    }
    
    func testLoginSavesSession() {
        viewModel.emailInput.accept("test@example.com")
        viewModel.passwordInput.accept("password1")
        
        var successCalled = false
        viewModel.onLoginSuccess = { successCalled = true }
        
        viewModel.submitTapped.accept(())
        
        XCTAssertTrue(successCalled)
        XCTAssertEqual(mockSession.savedEmail, "test@example.com")
    }
}

final class PostsViewModelTests: XCTestCase {
    var viewModel: PostsViewModel!
    var mockRepository: MockPostRepository!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        mockRepository = MockPostRepository()
        viewModel = PostsViewModel(repository: mockRepository)
        disposeBag = DisposeBag()
    }
    
    func testLoadPostsSyncsThenEmitsPosts() {
        let posts = [Post(id: 1, userId: 1, title: "Test", body: "Body")]
        
        // Use a delayed observable to simulate posts arriving after sync
        let postsSubject = PublishSubject<[Post]>()
        mockRepository.observePostsResult = postsSubject.asObservable()
        
        viewModel = PostsViewModel(repository: mockRepository)
        disposeBag = DisposeBag()
        
        var result: [Post]?
        viewModel.posts
            .subscribe(onNext: { result = $0 })
            .disposed(by: disposeBag)
        
        
        XCTAssertEqual(result?.count, 0)
        
        
        postsSubject.onNext(posts)
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.title, "Test")
    }
    
    func testLoadPostsSetsLoadingState() {
        mockRepository.syncPostsResult = Completable.create { observer in
            // Simulate delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                observer(.completed)
            }
            return Disposables.create()
        }
        
        var states: [Bool] = []
        viewModel.isLoading
            .subscribe(onNext: { states.append($0) })
            .disposed(by: disposeBag)
        
        viewModel.loadPosts()
        
        XCTAssertTrue(states.contains(true))
    }
    
    func testToggleFavoriteCallsRepository() {
        let post = Post(id: 5, userId: 1, title: "Test", body: "Body")
        
        viewModel.toggleFavorite(post: post)
        
        XCTAssertEqual(mockRepository.toggledPostId, 5)
    }
}
