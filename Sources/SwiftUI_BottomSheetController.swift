import UIKit
import SwiftUI

// MARK: - SwiftUI Handshake

struct BottomSheetContainerRepresentable<BottomContent: View, SheetHeader: View, SheetContent: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = BottomSheetController
    
    let isPresented: Binding<Bool>
    let configuration: BottomSheetConfiguration
    @ViewBuilder let bottomContent: () -> BottomContent
    let sheetHeader: SheetHeader?
    @ViewBuilder let sheetContent: () -> SheetContent
        
    func makeUIViewController(context: Context) -> BottomSheetController {
        let headerViewController: UIViewController? = {
            guard let sheetHeader else { return nil }
            let controller = UIHostingController(rootView: sheetHeader)
            if #available(iOS 16.4, *) {
                controller.safeAreaRegions = []
            }
            return controller
        }()
        
        let contentViewController = UIHostingController(rootView: sheetContent())
        if #available(iOS 16.4, *) {
            contentViewController.safeAreaRegions = []
        }
        contentViewController.sizingOptions = .intrinsicContentSize
        
        return BottomSheetController(
            configuration: configuration,
            bottomContentViewController: UIHostingController(rootView: bottomContent()),
            headerViewController: headerViewController,
            contentViewController: contentViewController
        )
    }
    
    func updateUIViewController(_ uiViewController: BottomSheetController, context: Context) {
        uiViewController.isSheetPresented = isPresented.wrappedValue
        uiViewController.configuration = configuration
    }
}

extension BottomSheetContainerRepresentable {
    init(
        isPresented: Binding<Bool>,
        configuration: BottomSheetConfiguration,
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        sheetHeader: SheetHeader,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    ) {
        self.isPresented = isPresented
        self.configuration = configuration
        self.bottomContent = bottomContent
        self.sheetHeader = sheetHeader
        self.sheetContent = sheetContent
    }
}

extension BottomSheetContainerRepresentable where SheetHeader == Never {
    init(
        isPresented: Binding<Bool>,
        configuration: BottomSheetConfiguration,
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    ) {
        self.isPresented = isPresented
        self.configuration = configuration
        self.bottomContent = bottomContent
        self.sheetHeader = nil
        self.sheetContent = sheetContent
    }
}

extension View {
    public func bottomSheet<SheetHeader: View, SheetContent: View>(
        isPresented: Binding<Bool>,
        configuration: BottomSheetConfiguration = .default,
        sheetHeader: @escaping () -> SheetHeader,
        sheetContent: @escaping () -> SheetContent
    ) -> some View {
        BottomSheetContainerRepresentable(
            isPresented: isPresented,
            configuration: configuration,
            bottomContent: { self },
            sheetHeader: sheetHeader(),
            sheetContent: sheetContent
        )
        .ignoresSafeArea()
    }
    
    public func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        configuration: BottomSheetConfiguration = .default,
        sheetContent: @escaping () -> SheetContent
    ) -> some View {
        BottomSheetContainerRepresentable(
            isPresented: isPresented,
            configuration: configuration,
            bottomContent: { self },
            sheetContent: sheetContent
        )
        .ignoresSafeArea()
    }
}
