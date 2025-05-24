//
//  UIViewController+Helpers.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//

import UIKit

extension UIViewController {
  func forceOrientation(_ orientation: UIInterfaceOrientation) {
    if #available(iOS 16.0, *) {
      guard let windowScene = view.window?.windowScene else { return }
      windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation.toMask)) { error in
        print("Error requesting geometry update: \(error)")
      }
    } else {
      UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
  }
}

extension UIInterfaceOrientation {
  var toMask: UIInterfaceOrientationMask {
    switch self {
    case .portrait:
      return .portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    default:
      return .portrait
    }
  }
}
