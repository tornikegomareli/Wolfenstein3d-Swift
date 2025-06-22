//
//  MotionManager.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


import CoreMotion
import UIKit
import Engine

protocol MotionManagerDelegate: AnyObject {
  func motionManager(_ manager: MotionManager, didUpdateRotation angle: Double)
}

class MotionManager {
  
  weak var delegate: MotionManagerDelegate?
  
  private let motionManager = CMMotionManager()
  private var lastYaw: Double?
  
  
  func startTracking() {
    guard motionManager.isDeviceMotionAvailable else {
      print("Device motion is not available")
      return
    }
    
    motionManager.deviceMotionUpdateInterval = GameConfig.Input.gyroUpdateInterval
    
    motionManager.startDeviceMotionUpdates(
      using: .xArbitraryCorrectedZVertical,
      to: .main
    ) { [weak self] motion, error in
      guard let self = self,
            let motion = motion,
            error == nil else { return }
      
      self.processMotion(motion)
    }
  }
  
  func stopTracking() {
    motionManager.stopDeviceMotionUpdates()
    lastYaw = nil
  }
  
  func reset() {
    lastYaw = nil
  }
  
  
  private func processMotion(_ motion: CMDeviceMotion) {
    let currentYaw = motion.attitude.yaw
    
    guard let lastYaw = lastYaw else {
      self.lastYaw = currentYaw
      return
    }
    
    var deltaRotation = currentYaw - lastYaw
    
    if deltaRotation > .pi {
      deltaRotation -= 2 * .pi
    } else if deltaRotation < -.pi {
      deltaRotation += 2 * .pi
    }
    
    self.lastYaw = currentYaw
    
    delegate?.motionManager(self, didUpdateRotation: deltaRotation)
  }
  
  // MARK: - Status
  
  var isTracking: Bool {
    return motionManager.isDeviceMotionActive
  }
}
