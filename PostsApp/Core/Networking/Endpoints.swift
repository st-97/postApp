//
//  Endpoints.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import Foundation
import Alamofire
 
enum APIEndpoint {
    case posts
    case comments(postId: Int)
}
 
extension APIEndpoint {
 
    private static let baseURL = "https://jsonplaceholder.typicode.com"
 
    var path: String {
        switch self {
        case .posts:
            return "/posts"
        case .comments(let postId):
            return "/posts/\(postId)/comments"
        }
    }
 
    var url: URL {
         URL(string: Self.baseURL + path)!
    }
 
    var method: HTTPMethod { .get }
 
    var parameters: Parameters? { nil }
 
    var encoding: ParameterEncoding { URLEncoding.default }
 
    var headers: HTTPHeaders { .default }
}
 
