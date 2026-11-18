//
//  ModalPresenter.swift
//  Finora
//
//  Coordinator/Main
//
//  Detail screens open as a modal sheet with their own navigation bar instead of
//  being pushed. Every tab beyond the fourth lives inside iOS's "More" screen,
//  where pushing onto a tab's own navigation controller does not reliably show
//  anything; presenting works from every tab.
//

import UIKit

extension UINavigationController {

    /// Presents `controller` in its own navigation controller with a Close button.
    func presentModal(_ controller: UIViewController) {
        controller.navigationItem.largeTitleDisplayMode = .never
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in self?.dismissModal() }
        )
        present(UINavigationController(rootViewController: controller), animated: true)
    }

    func dismissModal() {
        dismiss(animated: true)
    }
}
