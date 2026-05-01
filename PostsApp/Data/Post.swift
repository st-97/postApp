import Foundation
import RealmSwift

struct Post: Codable, Equatable, Hashable{
    let id: Int
    let userId: Int
    let title: String
    let body: String
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, userId, title, body
    }
}
extension Post {
    func toRealmObject() -> PostObject {
        PostObject(
            id: id,
            userId: userId,
            title: title,
            body: body,
            isFavorite: isFavorite
        )
    }
}
struct Comment:Codable, Equatable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
    
    func toDomain() -> Comment {
        Comment(id: id, postId: postId, name: name, email: email, body: body)
    }
 
    func toRealmObject() -> CommentObject {
        CommentObject(id: id, postId: postId, name: name, email: email, body: body)
    }
}


