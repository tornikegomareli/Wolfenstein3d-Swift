import Foundation

public class Weapon {
    public enum State {
        case idle
        case shooting
    }
    
    public private(set) var state: State = .idle
    public private(set) var currentFrame: Int = 0
    
    private let shootAnimationFrames = 5
    private let frameTime: TimeInterval = 0.08
    private var animationTimer: TimeInterval = 0
    
    public init() {}
    
    public func startShooting() {
        guard state == .idle else { return }
        state = .shooting
        currentFrame = 1
        animationTimer = 0
    }
    
    public func update(deltaTime: TimeInterval) {
        guard state == .shooting else { return }
        
        animationTimer += deltaTime
        
        if animationTimer >= frameTime {
            animationTimer = 0
            currentFrame += 1
            
            if currentFrame > shootAnimationFrames {
                currentFrame = 1
                state = .idle
            }
        }
    }
    
    public func getCurrentSpriteName() -> String {
        return "shoot_\(currentFrame)"
    }
}