//
//  PAErrorLabel.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import UIKit

final class PAErrorLabel: UILabel {
    
 
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        font = UIFont.systemFont(ofSize: 13, weight: .medium)
        textColor = .systemRed
        numberOfLines = 0
        textAlignment = .left
        
         adjustsFontForContentSizeCategory = true
        
         isHidden = true
    }
    
    
    override var text: String? {
        didSet {
            
            isHidden = text?.isEmpty ?? true
        }
    }
}
