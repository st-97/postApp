//
//  LoginViewModelProtocol.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import Foundation
import RxSwift
import RxCocoa

 
protocol LoginViewModelProtocol {
    var emailInput: BehaviorRelay<String> { get }
    var passwordInput: BehaviorRelay<String> { get }
    var submitTapped: PublishRelay<Void> { get }
    
    var isSubmitEnabled: Driver<Bool> { get }
    var emailValidationMessage: Driver<String?> { get }
    var passwordValidationMessage: Driver<String?> { get }
    var onLoginSuccess: (() -> Void)? { get set }
}
