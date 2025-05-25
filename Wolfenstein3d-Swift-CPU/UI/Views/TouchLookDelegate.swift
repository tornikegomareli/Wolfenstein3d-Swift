// UI/Views/TouchLookView.swift
import UIKit

protocol TouchLookDelegate: AnyObject {
    func touchLookDidMove(deltaX: CGFloat, deltaY: CGFloat)
}

class TouchLookView: UIView {
    // MARK: - Properties
    
    weak var delegate: TouchLookDelegate?
    
    private var lastTouchLocation: CGPoint?
    private var activeTouches: Set<UITouch> = []
    private let sensitivity: CGFloat = GameConfig.UI.lookSensitivity
    
    // Visual feedback
    private var touchIndicator: UIView?
    private let indicatorSize: CGFloat = 80
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = false
        
        // Optional: Add a subtle visual hint
        let hintLabel = UILabel()
        hintLabel.text = "Touch & Drag to Look"
        hintLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        hintLabel.font = UIFont.systemFont(ofSize: 14)
        hintLabel.sizeToFit()
        hintLabel.center = CGPoint(x: bounds.width / 2, y: 30)
        hintLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        addSubview(hintLabel)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        activeTouches.insert(touch)
        lastTouchLocation = touch.location(in: self)
        
        // Show touch indicator
        showTouchIndicator(at: lastTouchLocation!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              activeTouches.contains(touch),
              let lastLocation = lastTouchLocation else { return }
        
        let currentLocation = touch.location(in: self)
        
        // Calculate delta movement
        let deltaX = currentLocation.x - lastLocation.x
        let deltaY = currentLocation.y - lastLocation.y
        
        // Update touch indicator position
        touchIndicator?.center = currentLocation
        
        // Apply sensitivity and notify delegate
        delegate?.touchLookDidMove(
            deltaX: deltaX * sensitivity,
            deltaY: deltaY * sensitivity
        )
        
        lastTouchLocation = currentLocation
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEnd(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEnd(touches)
    }
    
    // MARK: - Private Methods
    
    private func handleTouchEnd(_ touches: Set<UITouch>) {
        for touch in touches {
            activeTouches.remove(touch)
        }
        
        if activeTouches.isEmpty {
            lastTouchLocation = nil
            hideTouchIndicator()
        }
    }
    
    private func showTouchIndicator(at location: CGPoint) {
        if touchIndicator == nil {
            touchIndicator = UIView(frame: CGRect(x: 0, y: 0, width: indicatorSize, height: indicatorSize))
            touchIndicator?.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            touchIndicator?.layer.cornerRadius = indicatorSize / 2
            touchIndicator?.layer.borderWidth = 2
            touchIndicator?.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            touchIndicator?.isUserInteractionEnabled = false
        }
        
        touchIndicator?.center = location
        touchIndicator?.alpha = 0
        
        if let indicator = touchIndicator {
            addSubview(indicator)
            
            UIView.animate(withDuration: 0.2) {
                indicator.alpha = 1
            }
        }
    }
    
    private func hideTouchIndicator() {
        UIView.animate(withDuration: 0.2, animations: {
            self.touchIndicator?.alpha = 0
        }) { _ in
            self.touchIndicator?.removeFromSuperview()
        }
    }
}