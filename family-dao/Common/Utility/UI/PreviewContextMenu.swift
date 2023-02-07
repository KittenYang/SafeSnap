//
//  PreviewContextMenu.swift
//  family-dao
//
//  Created by KittenYang on 1/24/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI

//@ViewBuilder
func RoundedText(_ txt: String, font: CGFloat = 14.0) -> some View {
    Text(txt)
        .font(.rounded(size: font))
}

extension View {
	func contextMenuWithPreview<Content: View>(
		actions: [UIAction],
		@ViewBuilder preview: @escaping () -> Content
	) -> some View {
		self.overlay(
			InteractionView(
				preview: preview,
				menu: UIMenu(title: "", children: actions),
				didTapPreview: {}
			)
		)
	}
}

private struct InteractionView<Content: View>: UIViewRepresentable {
	@ViewBuilder let preview: () -> Content
	let menu: UIMenu
	let didTapPreview: () -> Void
	
	func makeUIView(context: Context) -> UIView {
		let view = UIView()
		view.backgroundColor = .clear
		let menuInteraction = UIContextMenuInteraction(delegate: context.coordinator)
		view.addInteraction(menuInteraction)
		return view
	}
	
	func updateUIView(_ uiView: UIView, context: Context) { }
	
	func makeCoordinator() -> Coordinator {
		Coordinator(
			preview: preview(),
			menu: menu,
			didTapPreview: didTapPreview
		)
	}
	
	class Coordinator: NSObject, UIContextMenuInteractionDelegate {
		let preview: Content
		let menu: UIMenu
		let didTapPreview: () -> Void
		
		init(preview: Content, menu: UIMenu, didTapPreview: @escaping () -> Void) {
			self.preview = preview
			self.menu = menu
			self.didTapPreview = didTapPreview
		}
		
		func contextMenuInteraction(
			_ interaction: UIContextMenuInteraction,
			configurationForMenuAtLocation location: CGPoint
		) -> UIContextMenuConfiguration? {
			UIContextMenuConfiguration(
				identifier: nil,
				previewProvider: { [weak self] () -> UIViewController? in
					guard let self = self else { return nil }
					return UIHostingController(rootView: self.preview)
				},
				actionProvider: { [weak self] _ in
					guard let self = self else { return nil }
					return self.menu
				}
			)
		}
		
		func contextMenuInteraction(
			_ interaction: UIContextMenuInteraction,
			willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
			animator: UIContextMenuInteractionCommitAnimating
		) {
			animator.addCompletion(self.didTapPreview)
		}
	}
}

// MARK: ------
private final class PreviewHostingController<Content: View>: UIHostingController<Content> {
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let window = view.window {
			preferredContentSize.width = window.frame.size.width - 32
		}
		
		let targetSize = view.intrinsicContentSize
		preferredContentSize.height = targetSize.height
	}
}

extension View {
	func snapshot() -> UIImage {
		let controller = UIHostingController(rootView: self)
		let view = controller.view

		let targetSize = controller.view.intrinsicContentSize
		view?.bounds = CGRect(origin: .zero, size: targetSize)
		view?.backgroundColor = .clear

		let renderer = UIGraphicsImageRenderer(size: targetSize)

		return renderer.image { _ in
			view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
		}
	}
}

//func contextMenuInteraction(
//	_ interaction: UIContextMenuInteraction,
//	previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
//) -> UITargetedPreview? {
//	targedPreview
//}
//
//func contextMenuInteraction(
//	_ interaction: UIContextMenuInteraction,
//	previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
//) -> UITargetedPreview? {
//	targedPreview
//}
//
//private var targedPreview: UITargetedPreview? {
//	let parameters = UIPreviewParameters()
//	parameters.backgroundColor = .clear
//	return UITargetedPreview(view: UIImageView(image: snapshot), parameters: parameters)
//}




//// MARK: - Custom Menu Context Implementation
//struct PreviewContextMenu<Content: View> {
//	let destination: Content
//	let actionProvider: UIContextMenuActionProvider?
//
//	init(destination: Content, actionProvider: UIContextMenuActionProvider? = nil) {
//		self.destination = destination
//		self.actionProvider = actionProvider
//	}
//}
//
//// UIView wrapper with UIContextMenuInteraction
//struct PreviewContextView<Content: View>: UIViewRepresentable {
//
//	let menu: PreviewContextMenu<Content>
//	let didCommitView: () -> Void
//
//	func makeUIView(context: Context) -> UIView {
//		let view = UIView()
//		view.backgroundColor = .clear
//		let menuInteraction = UIContextMenuInteraction(delegate: context.coordinator)
//		view.addInteraction(menuInteraction)
//		return view
//	}
//
//	func updateUIView(_ uiView: UIView, context: Context) { }
//
//	func makeCoordinator() -> Coordinator {
//		return Coordinator(menu: self.menu, didCommitView: self.didCommitView)
//	}
//
//	class Coordinator: NSObject, UIContextMenuInteractionDelegate {
//
//		let menu: PreviewContextMenu<Content>
//		let didCommitView: () -> Void
//
//		init(menu: PreviewContextMenu<Content>, didCommitView: @escaping () -> Void) {
//			self.menu = menu
//			self.didCommitView = didCommitView
//		}
//
//		func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//			return UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
//				UIHostingController(rootView: self.menu.destination)
//			}, actionProvider: self.menu.actionProvider)
//		}
//
//		func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
//			animator.addCompletion(self.didCommitView)
//		}
//
//	}
//}
//
//// Add context menu modifier
//extension View {
//	func contextMenu<Content: View>(_ menu: PreviewContextMenu<Content>) -> some View {
//		self.modifier(PreviewContextViewModifier(menu: menu))
//	}
//}
//
//struct PreviewContextViewModifier<V: View>: ViewModifier {
//
//	let menu: PreviewContextMenu<V>
//	@Environment(\.presentationMode) var mode
//
//	@State var isActive: Bool = false
//
//	func body(content: Content) -> some View {
//		Group {
//			if isActive {
//				menu.destination
//			} else {
//				content.overlay(PreviewContextView(menu: menu, didCommitView: { self.isActive = true }))
//			}
//		}
//	}
//}
