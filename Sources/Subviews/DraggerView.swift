import UIKit

final class DraggerView: UIView {
    // MARK: Subviews
    
    private(set) lazy var draggerBarContainer: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var draggerBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiaryLabel
        view.layer.cornerRadius = 2.5
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DraggerView {
    func setUpSubviews() {
        backgroundColor = .clear
        
        addSubview(draggerBarContainer)
        draggerBarContainer.addSubview(draggerBar)
        
        NSLayoutConstraint.activate([
            draggerBarContainer.topAnchor.constraint(equalTo: topAnchor),
            draggerBarContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            draggerBarContainer.widthAnchor.constraint(equalToConstant: 50),
            draggerBarContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            draggerBar.widthAnchor.constraint(equalToConstant: 36),
            draggerBar.heightAnchor.constraint(equalToConstant: 5),
            draggerBar.topAnchor.constraint(equalTo: draggerBarContainer.topAnchor, constant: 4),
            draggerBar.centerXAnchor.constraint(equalTo: draggerBarContainer.centerXAnchor),
        ])
    }
}
