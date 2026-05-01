//
//  CommentsCell.swift
//  PostsApp
//
//  Created by Shaikh Taha on 30/04/2026.
//

import UIKit

class CommentsCell: UITableViewCell {
    @IBOutlet weak var avatar: UIView!
    
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var postContent: UILabel!
    static let identifier = "CommentsCell"
    static let nibName = "CommentsCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarLabel.text = nil
        username.text = nil
        email.text = nil
        postContent.text = nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        avatar.layer.cornerRadius = 5
        avatar.clipsToBounds = true
        avatar.backgroundColor = AppTheme.accent.withAlphaComponent(0.3)
        
        avatarLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        avatarLabel.textColor = AppTheme.accent
        avatarLabel.textAlignment = .center
        
        username.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        username.textColor = .label
        username.numberOfLines = 1
        
        email.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        email.textColor = AppTheme.textSecondary
        email.numberOfLines = 1
        
        postContent.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        postContent.textColor = .label
        postContent.numberOfLines = 0
    }
    
    func configure(with comment: Comment) {
        avatarLabel.text = String(comment.name.prefix(1).uppercased())
        username.text = comment.name
        email.text = comment.email
        postContent.text = comment.body
    }
    
}
