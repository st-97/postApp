//
//  PAButton.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import UIKit
import UIKit

final class PAButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }
    
    private func setupUI() {
        backgroundColor = AppTheme.accent
        setTitleColor(.white, for: .normal)
        setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
        setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 12
        
        heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        addTarget(self, action: #selector(down), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func down() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.alpha = 0.9
        }
    }
    
    @objc private func up() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = self.isEnabled
                    ? AppTheme.accent
                    : AppTheme.accent.withAlphaComponent(0.6)
            }
        }
    }
}
