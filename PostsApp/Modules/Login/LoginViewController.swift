//
//  LoginViewController.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//
import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {

     
    var viewModel: LoginViewModel!

    private let disposeBag = DisposeBag()

    @IBOutlet weak var emailField: PATextField!
    @IBOutlet weak var passwordField: PATextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var submitButton: PAButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        emailErrorLabel.numberOfLines = 0
        passwordErrorLabel.numberOfLines = 0

        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true

        submitButton.isEnabled = false
        submitButton.alpha = 0.5
    }

    private func bindViewModel() {

        emailField.rx.text.orEmpty
            .bind(to: viewModel.emailInput)
            .disposed(by: disposeBag)

        passwordField.rx.text.orEmpty
            .bind(to: viewModel.passwordInput)
            .disposed(by: disposeBag)

        submitButton.rx.tap
            .bind(to: viewModel.submitTapped)
            .disposed(by: disposeBag)

        viewModel.isSubmitEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.submitButton.isEnabled = isEnabled
                UIView.animate(withDuration: 0.2) {
                    self?.submitButton.alpha = isEnabled ? 1.0 : 0.5
                }
            })
            .disposed(by: disposeBag)

        viewModel.emailValidationMessage
            .drive(onNext: { [weak self] message in
                self?.emailErrorLabel.text = message
                self?.emailErrorLabel.isHidden = message == nil
            })
            .disposed(by: disposeBag)

        viewModel.passwordValidationMessage
            .drive(onNext: { [weak self] message in
                self?.passwordErrorLabel.text = message
                self?.passwordErrorLabel.isHidden = message == nil
            })
            .disposed(by: disposeBag)
    }
}
