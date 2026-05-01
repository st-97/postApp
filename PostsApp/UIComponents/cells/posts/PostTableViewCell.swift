import UIKit

final class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    static let nibName = "PostTableViewCell"
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var avatarLabel: UILabel!
    
    var onFavoriteTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bodyLabel.text = nil
        userIdLabel.text = nil
        avatarLabel.text = nil
        onFavoriteTapped = nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        avatarView.layer.cornerRadius = 8
        avatarView.clipsToBounds = true
        avatarView.backgroundColor = AppTheme.accent.withAlphaComponent(0.3)
        
        avatarLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        avatarLabel.textColor = AppTheme.accent
        avatarLabel.textAlignment = .center
        
        containerView.backgroundColor = AppTheme.surface
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        
        bodyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = AppTheme.textSecondary
        bodyLabel.numberOfLines = 3
        
        userIdLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        userIdLabel.textColor = AppTheme.accent
        
        favoriteButton.tintColor = .systemPink
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    func configure(with post: Post) {
        titleLabel.text = post.title.capitalized
        bodyLabel.text = post.body.trimmingCharacters(in: .whitespacesAndNewlines)
        userIdLabel.text = "User \(post.userId)"
        avatarLabel.text = "U\(post.userId)"
        
        let heartImage = post.isFavorite
            ? UIImage(systemName: "heart.fill")
            : UIImage(systemName: "heart")
        favoriteButton.setImage(heartImage, for: .normal)
    }
    
    @objc private func favoriteButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
        onFavoriteTapped?()
    }
}
