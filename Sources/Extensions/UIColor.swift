import UIKit

extension UIColor {
    static let bottomSheetBackgroundColor: UIColor = .init { traits in
        return traits.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}
