import Foundation
import RealmSwift
import RxSwift
internal import Realm

protocol DatabaseServiceProtocol {
    func saveObjects<T: Object>(_ objects: [T])
    func fetchObjects<T: Object>(_ type: T.Type) -> [T]
    func deleteObject<T: Object>(_ object: T)
    func observeObjects<T: Object>(_ type: T.Type) -> Observable<[T]>
    func clearAllData()
}

final class DatabaseService: DatabaseServiceProtocol {
    
    private let queue = DispatchQueue(label: "com.postapp.database", qos: .utility)
    
    func saveObjects<T: Object>(_ objects: [T]) {
        queue.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(objects, update: .modified)
                    }
                } catch {
                    print("[DatabaseService] saveObjects failed: \(error)")
                }
            }
        }
    }
    
    func fetchObjects<T: Object>(_ type: T.Type) -> [T] {
        do {
            let realm = try Realm()
            return Array(realm.objects(type))
        } catch {
            print("[DatabaseService] fetchObjects failed: \(error)")
            return []
        }
    }
    
    func deleteObject<T: Object>(_ object: T) {
        let ref = ThreadSafeReference(to: object)
        queue.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    guard let resolved = realm.resolve(ref) else { return }
                    try realm.write { realm.delete(resolved) }
                } catch {
                    print("[DatabaseService] deleteObject failed: \(error)")
                }
            }
        }
    }
    
    func observeObjects<T: Object>(_ type: T.Type) -> Observable<[T]> {
        Observable.create { observer in
            do {
                let realm = try Realm()
                let results = realm.objects(type)
                let token = results.observe { changes in
                    switch changes {
                    case .initial(let collection),
                         .update(let collection, _, _, _):
                        observer.onNext(Array(collection))
                    case .error(let error):
                        observer.onError(error)
                    }
                }
                return Disposables.create { token.invalidate() }
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
    }
    
    func clearAllData() {
        queue.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.deleteAll()
                    }
                    print("[DatabaseService] All data cleared")
                } catch {
                    print("[DatabaseService] clearAllData failed: \(error)")
                }
            }
        }
    }
}

