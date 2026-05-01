//
//  PATextField.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//
import UIKit
final class PATextField: UITextField {

    private let padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = AppTheme.surface
        textColor = .label
        font = AppTheme.Font.bodyRegular
        tintColor = AppTheme.accent

        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor

        autocorrectionType = .no
        autocapitalizationType = .none
        adjustsFontForContentSizeCategory = true
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
