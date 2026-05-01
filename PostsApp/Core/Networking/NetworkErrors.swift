//
//  NetworkErrors.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import Foundation
import Alamofire

// MARK: - NetworkError

enum NetworkError: LocalizedError {
   case noConnection
   case invalidResponse
   case serverError(Int)
   case decodingFailure(String)
   case unknown

   var errorDescription: String? {
       switch self {
       case .noConnection:              return "No internet connection."
       case .invalidResponse:           return "Invalid server response."
       case .serverError(let code):     return "Server error (\(code))."
       case .decodingFailure(let msg):  return "Decoding failed: \(msg)"
       case .unknown:                   return "An unknown error occurred."
       }
   }

   static func from(_ afError: AFError) -> NetworkError {
       if let urlError = afError.underlyingError as? URLError,
          urlError.code == .notConnectedToInternet {
           return .noConnection
       }
       if let statusCode = afError.responseCode {
           return .serverError(statusCode)
       }
       if case .responseSerializationFailed = afError {
           return .decodingFailure(afError.localizedDescription)
       }
       return .unknown
   }
}
