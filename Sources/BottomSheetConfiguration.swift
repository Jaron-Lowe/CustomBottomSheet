import Foundation
import UIKit

public struct BottomSheetConfiguration: Equatable {
    public static let `default` = Self()
    
    var snapHeights: [CGFloat]
    var cornerRadius: CGFloat
    var shadowConfiguation: ShadowConfiguration = .default
    var isDraggerBarVisible: Bool = true
    
    // TODO: Implement
    var dismissInteractions: DismissInteraction = .all
    
    public init(
        snapHeights: [CGFloat] = [452],
        cornerRadius: CGFloat = 0,
        shadowConfiguation: ShadowConfiguration = .default,
        isDraggerBarVisible: Bool = true,
        dismissInteractions: DismissInteraction = .all
    ) {
        self.snapHeights = snapHeights
        self.cornerRadius = cornerRadius
        self.shadowConfiguation = shadowConfiguation
        self.isDraggerBarVisible = isDraggerBarVisible
        self.dismissInteractions = dismissInteractions
    }
    
}

extension BottomSheetConfiguration {
    public struct DismissInteraction: OptionSet, Equatable {
        // MARK: Composite Cases
        
        public static let all: Self = [.bottomSwipe, .dimmingViewTap]
        public static let none: Self = []
        
        // MARK: Single Cases
        
        public static let bottomSwipe = Self(rawValue: 1 << 0)
        public static let dimmingViewTap = Self(rawValue: 1 << 1)
        
        // MARK: OptionSet
        
        public var rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

public struct ShadowConfiguration: Equatable {
    public static let `default` = Self()
    
    var color: UIColor
    var offset: CGSize
    var opacity: Float
    var radius: CGFloat
    
    public init(
        color: UIColor = .black,
        offset: CGSize = .init(width: 0, height: -1),
        opacity: Float = 0.09,
        radius: CGFloat = 2
    ) {
        self.color = color
        self.offset = offset
        self.opacity = opacity
        self.radius = radius
    }
}
