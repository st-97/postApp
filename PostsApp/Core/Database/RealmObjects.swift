//
//  RealmObjects.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import RealmSwift
 
enum RealmProvider {
    static func realm() throws -> RealmSwift.Realm {
        try RealmSwift.Realm()
    }
}

final class PostObject: Object {

    @Persisted(primaryKey: true) var id: Int
    @Persisted var userId: Int
    @Persisted var title: String
    @Persisted var body: String
    @Persisted var isFavorite: Bool = false

    convenience init(
        id: Int,
        userId: Int,
        title: String,
        body: String,
        isFavorite: Bool = false
    ) {
        self.init()
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.isFavorite = isFavorite
    }
}
extension PostObject {
    func toDomain() -> Post {
        Post(
            id: id,
            userId: userId,
            title: title,
            body: body,
            isFavorite: isFavorite
        )
    }
}
final class CommentObject: Object {
 
    @Persisted(primaryKey: true) var id: Int
    @Persisted var postId: Int
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var body: String
 
    convenience init(id: Int, postId: Int, name: String, email: String, body: String) {
        self.init()
        self.id     = id
        self.postId = postId
        self.name   = name
        self.email  = email
        self.body   = body
    }
}
 
