//
//  ThemeManager.swift
//  beanthere
//
//  Created by Sarah Fedorchak on 4/26/25.
//

import UIKit

func overrideUserInterfaceStyleForAllWindows(style: UIUserInterfaceStyle) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return
    }
    
    for window in windowScene.windows {
        UIView.transition(with: window, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            window.overrideUserInterfaceStyle = style
        }, completion: nil)
    }
}
