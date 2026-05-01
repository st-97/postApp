//
//  LoginViewModel.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: LoginViewModelProtocol {
 
     
 
    let emailInput    = BehaviorRelay<String>(value: "")
    let passwordInput = BehaviorRelay<String>(value: "")
    let submitTapped  = PublishRelay<Void>()
 
 
    let isSubmitEnabled: Driver<Bool>
    let emailValidationMessage: Driver<String?>
    let passwordValidationMessage: Driver<String?>
     
    var onLoginSuccess: (() -> Void)?
 
 
    private let sessionManager: SessionManagerProtocol
    private let validator: LoginValidatorProtocol
 
 
    private let disposeBag = DisposeBag()
 
 
    init(
        sessionManager: SessionManagerProtocol = SessionManager.shared,
        validator: LoginValidatorProtocol = LoginValidator()
    ) {
        self.sessionManager = sessionManager
        self.validator = validator
        let isEmailValid = emailInput
            .map { [validator] in validator.isEmailValid($0) }
            .share(replay: 1, scope: .whileConnected)
 
        let isPasswordValid = passwordInput
            .map { [validator] in validator.isPasswordValid($0) }
            .share(replay: 1, scope: .whileConnected)
 
         isSubmitEnabled = Observable
            .combineLatest(isEmailValid, isPasswordValid) { $0 && $1 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
        emailValidationMessage = emailInput
            .skip(1)
            .map { [validator] email -> String? in
                guard !email.isEmpty else { return nil }
                return validator.emailValidationMessage(for: email)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
 
        passwordValidationMessage = passwordInput
            .skip(1)
            .map { [validator] password -> String? in
                guard !password.isEmpty else { return nil }
                return validator.passwordValidationMessage(for: password)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
 
         submitTapped
            .withLatestFrom(emailInput)
            .subscribe(onNext: { [weak self] email in
                self?.sessionManager.saveSession(email: email)
                self?.onLoginSuccess?()
            })
            .disposed(by: disposeBag)
    }
}

 
protocol LoginValidatorProtocol {
    func isEmailValid(_ email: String) -> Bool
    func isPasswordValid(_ password: String) -> Bool
    func emailValidationMessage(for email: String) -> String?
    func passwordValidationMessage(for password: String) -> String?
}

 
final class LoginValidator: LoginValidatorProtocol {
    
 
    static let passwordMinLength = 8
    static let passwordMaxLength = 15
    private static let emailPattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
    
 
    func isEmailValid(_ email: String) -> Bool {
        email.range(of: Self.emailPattern, options: .regularExpression) != nil
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        (Self.passwordMinLength...Self.passwordMaxLength).contains(password.count)
    }
    
    func emailValidationMessage(for email: String) -> String? {
        isEmailValid(email) ? nil : "Please enter a valid email address."
    }
    
    func passwordValidationMessage(for password: String) -> String? {
        isPasswordValid(password) 
            ? nil 
            : "Password must be \(Self.passwordMinLength)–\(Self.passwordMaxLength) characters."
    }
}
 
protocol SessionManagerProtocol {
    func saveSession(email: String)
    func clearSession()
    func getCurrentSession() -> String?
}

