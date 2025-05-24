// Managers/MotionManager.swift
import CoreMotion
import UIKit

protocol MotionManagerDelegate: AnyObject {
    func motionManager(_ manager: MotionManager, didUpdateRotation angle: Double)
}

class MotionManager {
    // MARK: - Properties
    
    weak var delegate: MotionManagerDelegate?
    
    private let motionManager = CMMotionManager()
    private var lastYaw: Double?
    
    // MARK: - Public Methods
    
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
    
    // MARK: - Private Methods
    
    private func processMotion(_ motion: CMDeviceMotion) {
        let currentYaw = motion.attitude.yaw
        
        guard let lastYaw = lastYaw else {
            self.lastYaw = currentYaw
            return
        }
        
        var deltaRotation = currentYaw - lastYaw
        
        // Handle wrap-around from -π to π
        if deltaRotation > .pi {
            deltaRotation -= 2 * .pi
        } else if deltaRotation < -.pi {
            deltaRotation += 2 * .pi
        }
        
        self.lastYaw = currentYaw
        
        // Notify delegate
        delegate?.motionManager(self, didUpdateRotation: deltaRotation)
    }
    
    // MARK: - Status
    
    var isTracking: Bool {
        return motionManager.isDeviceMotionActive
    }
}