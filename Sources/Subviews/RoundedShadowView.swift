import UIKit

open class RoundedShadowContainerView: UIView {
    // MARK: Properties
    
    open var cornerRadius: CGFloat = 0 {
        didSet {
            contentView.layer.cornerRadius = cornerRadius
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    open var shadowConfig: ShadowConfiguration = .default {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        
        setUpSubviews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        configureShadow()
    }
}

private extension RoundedShadowContainerView {
    func setUpSubviews() {
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func configureShadow() {
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shadowColor = shadowConfig.color.cgColor
        layer.shadowOffset = shadowConfig.offset
        layer.shadowOpacity = shadowConfig.opacity
        layer.shadowRadius = shadowConfig.radius
    }
}

