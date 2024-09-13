import UIKit
import SwiftUI

public final class BottomSheetController: UIViewController {
    // MARK: Subviews
    
    private  var sheetContainerView: RoundedShadowContainerView = {
        let view = RoundedShadowContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView.backgroundColor = .bottomSheetBackgroundColor
        view.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private var draggerView: DraggerView = {
        let view = DraggerView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: Drag Handling
    
    private static let nonContentTag = 999
    private var sheetYOffsetConstraint: NSLayoutConstraint!
    private var scrollViewHeightConstraint: NSLayoutConstraint!
    private var dragState: DragState = .initial
    private var propertyAnimator: UIViewPropertyAnimator?
    private var frozenScrollOffset: CGFloat = 0
    
    // MARK: Parameter Properties
    
    public var isSheetPresented: Bool = false {
        didSet {
            snapToPoint(nearestSnapPoint(), duration: 0.275)
        }
    }
    
    public var configuration: BottomSheetConfiguration {
        didSet {
            sheetContainerView.cornerRadius = configuration.cornerRadius
            sheetContainerView.shadowConfig = configuration.shadowConfiguation
            draggerView.isHidden = !configuration.isDraggerBarVisible
        }
    }
    
    // MARK: Init
    
    public init(
        configuration: BottomSheetConfiguration = .default,
        bottomContentViewController: UIViewController,
        headerViewController: UIViewController? = nil,
        contentViewController: UIViewController
    ) {
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
        setUpSubviews(
            bottomContentViewController: bottomContentViewController,
            headerViewController: headerViewController,
            contentViewController: contentViewController
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        scrollView.contentInset = .init(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }
}

private extension BottomSheetController {
    func setUpSubviews(
        bottomContentViewController: UIViewController,
        headerViewController: UIViewController?,
        contentViewController: UIViewController
    ) {
        // Embed Bottom Content
        addChild(bottomContentViewController)
        bottomContentViewController.didMove(toParent: self)
        bottomContentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomContentViewController.view)
        
        view.addSubview(sheetContainerView)
        
        sheetContainerView.contentView.addSubview(scrollView)
        let scrollViewTopConstraint: NSLayoutConstraint
        scrollView.delegate = self
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(dragGestureRecognized(_:)))
        
        // Embed Header Content
        if let headerViewController, let headerView = headerViewController.view {
            addChild(headerViewController)
            headerViewController.didMove(toParent: self)
            sheetContainerView.contentView.addSubview(headerView)
            headerView.backgroundColor = .clear
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.setContentHuggingPriority(.required, for: .vertical)
            headerView.tag = Self.nonContentTag
            headerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragGestureRecognized(_:))))
            
            scrollViewTopConstraint = scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
            
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: sheetContainerView.contentView.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: sheetContainerView.contentView.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: sheetContainerView.contentView.trailingAnchor),
            ])
        } else {
            scrollViewTopConstraint = scrollView.topAnchor.constraint(equalTo: sheetContainerView.contentView.topAnchor)
        }
        
        draggerView.tag = Self.nonContentTag
        draggerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragGestureRecognized(_:))))
        draggerView.draggerBarContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(draggerBarTapped(_:))))
        sheetContainerView.contentView.addSubview(draggerView)
        
        // Embed Sheet Content
        addChild(contentViewController)
        contentViewController.didMove(toParent: self)
        contentViewController.view.backgroundColor = .clear
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentViewController.view)

        sheetYOffsetConstraint = view.bottomAnchor.constraint(equalTo: sheetContainerView.topAnchor, constant: 0)
        scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([
            bottomContentViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            bottomContentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            draggerView.topAnchor.constraint(equalTo: sheetContainerView.contentView.topAnchor),
            draggerView.leadingAnchor.constraint(equalTo: sheetContainerView.contentView.leadingAnchor),
            draggerView.trailingAnchor.constraint(equalTo: sheetContainerView.contentView.trailingAnchor),
            draggerView.heightAnchor.constraint(equalToConstant: 15),
            
            sheetContainerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            sheetContainerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            sheetContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetYOffsetConstraint,
            
            scrollViewTopConstraint,
            scrollViewHeightConstraint,
            scrollView.leadingAnchor.constraint(equalTo: sheetContainerView.contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sheetContainerView.contentView.trailingAnchor),
            
            contentViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        sheetContainerView.frame = .init(x: 0, y: UIScreen.main.bounds.height + 100, width: 0, height: 0)
        
        view.layoutIfNeeded()
        snapToPoint(nearestSnapPoint())

    }
}
 
// MARK: - Drag & Snap

private extension BottomSheetController {
    @objc func draggerBarTapped(_ sender: UITapGestureRecognizer) {
        snapToPoint(nextSnapPoint(shouldWrap: true), duration: 0.3)
    }
    
    @objc func dragGestureRecognized(_ sender: UIPanGestureRecognizer) {
        dragState.isDraggingNonContent = sender.view?.tag == Self.nonContentTag
        
        switch sender.state {
        case .began:
            stopSnapAnimation()
            dragState.dragStartHeight = sheetYOffsetConstraint.constant
            
        case .changed:
            let translation = sender.translation(in: view).y
            if isDraggableFromScrollView() || dragState.isDraggingNonContent {
                let maxHeight = configuration.snapHeights.max()!
                setTopOffset(min(maxHeight, max(0, dragState.dragStartHeight - translation + dragState.preDragTranslation)))
            } else {
                if translation > 0 {
                    dragState.preDragTranslation = translation
                }
            }
            
        case .cancelled, .ended, .failed:
            if isDraggableFromScrollView() || dragState.isDraggingNonContent {
                let velocity = sender.velocity(in: view).y
                let strength = abs(velocity)
                let snapPoint: CGFloat
                if strength >= 1400 {
                    if velocity > 0 { snapPoint = previousSnapPoint() }
                    else { snapPoint = nextSnapPoint() }
                }
                else { snapPoint = nearestSnapPoint() }
                snapToPoint(snapPoint, useSpring: strength >= 800)
            }
            dragState = .initial
            
        case .possible:
            break
            
        @unknown default:
            break
        }
    }
    
    func isDraggableFromScrollView() -> Bool {
        guard let maxHeight = configuration.snapHeights.max() else { return false }
        return sheetYOffsetConstraint.constant < maxHeight || scrollView.contentOffset.y <= 0
    }
    
    func snapToPoint(_ point: CGFloat, duration: TimeInterval = 0.4, useSpring: Bool = false) {
        if point == configuration.snapHeights.max() && point != sheetYOffsetConstraint.constant {
            scrollView.setContentOffset(scrollView.contentOffset, animated: true)
        }
        
        let animation = { [weak self] in
            guard let self else { return }
            setTopOffset(point)
        }
        
        stopSnapAnimation()
        
        if duration > 0 {
            let animator: UIViewPropertyAnimator
            if useSpring {
                let springParameters = UISpringTimingParameters(dampingRatio: 0.78)
                animator = UIViewPropertyAnimator(duration: duration, timingParameters: springParameters)
            } else {
                animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut)
            }
            animator.addAnimations(animation)
            propertyAnimator = animator
            propertyAnimator?.startAnimation()
        } else {
            animation()
        }
    }
    
    func stopSnapAnimation() {
        guard let propertyAnimator, propertyAnimator.state == .active else { return }
        
        propertyAnimator.stopAnimation(true)
        propertyAnimator.finishAnimation(at: .end)
    }
    
    func previousSnapPoint() -> CGFloat {
        let nearest = nearestSnapPoint()
        guard let index = configuration.snapHeights.firstIndex(of: nearest), index > 0 else { return nearest }
        return configuration.snapHeights[index - 1]
    }
    
    func nextSnapPoint(shouldWrap: Bool = false) -> CGFloat {
        let nearest = nearestSnapPoint()
        guard let index = configuration.snapHeights.firstIndex(of: nearest), index < (configuration.snapHeights.count - 1) else {
            if shouldWrap {
                return configuration.snapHeights[0]
            } else {
                return nearest
            }
        }
        return configuration.snapHeights[index + 1]
    }
    
    func nearestSnapPoint() -> CGFloat {
        guard isSheetPresented else { return 0 }
        let currentHeight = sheetYOffsetConstraint.constant
        var smallestDistance: (height: CGFloat, distance: CGFloat) = (height: 0, distance: CGFloat.greatestFiniteMagnitude)
        for snapHeight in configuration.snapHeights {
            let distance = abs(snapHeight - currentHeight)
            if distance < smallestDistance.distance {
                smallestDistance = (height: snapHeight, distance: distance)
            }
        }
        return smallestDistance.height
    }
    
    func setTopOffset(_ offset: CGFloat) {
        sheetYOffsetConstraint.constant = offset
        scrollViewHeightConstraint.constant = max(0, offset - scrollView.frame.minY)
        view.layoutIfNeeded()
    }
}

extension BottomSheetController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let maxHeight = configuration.snapHeights.max() else { return }
        if sheetYOffsetConstraint.constant < maxHeight && !dragState.isDraggingNonContent {
            scrollView.setContentOffset(.init(x: scrollView.contentOffset.x, y: frozenScrollOffset), animated: false)
        }
        
        if sheetYOffsetConstraint.constant >= maxHeight {
            frozenScrollOffset = max(0, scrollView.contentOffset.y)
        }
    }
}

/// Defines the state of an ongoing drag gesture.
struct DragState: Equatable {
    static let initial = Self()
    
    /// The height of the sheet a the start of the drag gesture.
    var dragStartHeight: CGFloat = 0
    
    /// Used to calculate the translation difference during the transition between scrollview scrolling and sheet dragging.
    var preDragTranslation: CGFloat = 0
    
    /// Indicates that the sheet is being dragged from non-content (dragger bar or header)
    var isDraggingNonContent = false
}


