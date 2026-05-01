//
//  NetworkService.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//


import Foundation
import Alamofire
import RxSwift
 
 
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> Single<T>
}
 
 
final class NetworkService: NetworkServiceProtocol {
    private let session: Session
 
    init(session: Session = .default) {
        self.session = session
    }
 
 
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> Single<T> {
        Single.create { [weak self] observer in
            guard let self else {
                observer(.failure(NetworkError.unknown))
                return Disposables.create()
            }
 
            let request = self.session.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                if let data = response.data {
                    print("RAW RESPONSE:")
                    print(String(data: data, encoding: .utf8) ?? "nil")
                }

                switch response.result {
                case .success(let value):
                    observer(.success(value))
                case .failure(let error):
                    observer(.failure(NetworkError.from(error)))
                }
            }
 
            return Disposables.create { request.cancel() }
        }
    }
}
 
