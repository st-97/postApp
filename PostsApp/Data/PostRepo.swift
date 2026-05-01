import Foundation
import RxSwift
import RealmSwift

protocol PostRepositoryProtocol {
    func syncPosts() -> Completable
    func observePosts() -> Observable<[Post]>
    func observeFavorites() -> Observable<[Post]>

    func toggleFavorite(postId: Int) -> Completable
    func removeFavorite(postId: Int) -> Completable

    func fetchComments(forPostId postId: Int) -> Observable<[Comment]>
}

final class PostRepository: PostRepositoryProtocol {

    private let networkService: NetworkServiceProtocol
    private let databaseService: DatabaseServiceProtocol

    init(networkService: NetworkServiceProtocol,
         databaseService: DatabaseServiceProtocol) {
        self.networkService = networkService
        self.databaseService = databaseService
    }

    func observeFavorites() -> Observable<[Post]> {
        databaseService
            .observeObjects(PostObject.self)
            .map { objects in
                objects
                    .filter { $0.isFavorite }
                    .map { $0.toDomain() }
            }
    }

    func syncPosts() -> Completable {
        remotePosts()
            .do(onSuccess: { [weak self] posts in
                guard let self else { return }

                let favoriteIds = Set(
                    self.databaseService
                        .fetchObjects(PostObject.self)
                        .filter { $0.isFavorite }
                        .map { $0.id }
                )

                let objects = posts.map { post in
                    let obj = PostObject(
                        id: post.id,
                        userId: post.userId,
                        title: post.title,
                        body: post.body
                    )
                    obj.isFavorite = favoriteIds.contains(post.id)
                    return obj
                }

                self.databaseService.saveObjects(objects)
            })
            .asCompletable()
    }

     

    func observePosts() -> Observable<[Post]> {
        databaseService
            .observeObjects(PostObject.self)
            .map { objects in
                
                return objects.map { $0.toDomain() }
            }
    }

     

    func fetchComments(forPostId postId: Int) -> Observable<[Comment]> {
        networkService
            .request(.comments(postId: postId))
            .asObservable()
            .do(onNext: { [weak self] (comments: [Comment]) in
                self?.databaseService.saveObjects(
                    comments.map { $0.toRealmObject() }
                )
            })
    }

     

    func toggleFavorite(postId: Int) -> Completable {
        return Completable.create { observer in
            
            DispatchQueue.global(qos: .utility).async {
                
                autoreleasepool {
                    do {
                        let realm = try RealmProvider.realm()
                        
                        guard let post = realm.object(ofType: PostObject.self,
                                                       forPrimaryKey: postId) else {
                            observer(.error(RepositoryError.objectNotFound))
                            return
                        }
                        
                        try realm.write {
                            post.isFavorite.toggle()
                        }
                        
                        observer(.completed)
                        
                    } catch {
                        observer(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    func removeFavorite(postId: Int) -> Completable {
        return Completable.create { observer in
            DispatchQueue.global(qos: .utility).async {
                autoreleasepool {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            if let object = realm.object(ofType: PostObject.self, forPrimaryKey: postId) {
                                realm.delete(object)
                            }
                        }
                        observer(.completed)
                    } catch {
                        observer(.error(error))
                    }
                }
            }
            return Disposables.create()
        }
    }

    private func remotePosts() -> Single<[Post]> {
        networkService
            .request(.posts)
            .do(
                onSuccess: { posts in
                    print("Remote Posts Success:", posts.count)
                },
                onError: { error in
                    print("Remote Posts Error:", error)
                }
            )
    }
}

 

enum RepositoryError: LocalizedError {
    case objectNotFound
    case selfDeallocated

    var errorDescription: String? {
        switch self {
        case .objectNotFound:
            return "The requested item was not found in the local database."
        case .selfDeallocated:
            return "Repository was deallocated during an operation."
        }
    }
}
