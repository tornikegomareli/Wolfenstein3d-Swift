import UIKit

protocol JoystickDelegate: AnyObject {
  func joystickDidMove(x: CGFloat, y: CGFloat)
  func joystickDidRelease()
}

class JoystickView: UIView {
  weak var delegate: JoystickDelegate?
  
  private var knobView: UIView!
  private let knobSize: CGFloat = UIConfig.UI.joystickKnobSize
  private var baseCenter: CGPoint = .zero
  private var isTracking = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    backgroundColor = UIColor(white: 0.2, alpha: UIConfig.UI.joystickAlpha)
    layer.cornerRadius = bounds.width / 2
    
    setupKnob()
  }
  
  private func setupKnob() {
    knobView = UIView(frame: CGRect(x: 0, y: 0, width: knobSize, height: knobSize))
    knobView.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
    knobView.layer.cornerRadius = knobSize / 2
    knobView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    addSubview(knobView)
    
    baseCenter = knobView.center
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    isTracking = true
    handleTouch(touch)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isTracking, let touch = touches.first else { return }
    handleTouch(touch)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isTracking = false
    returnToCenter()
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    isTracking = false
    returnToCenter()
  }
  
  private func handleTouch(_ touch: UITouch) {
    let location = touch.location(in: self)
    let distance = distanceFrom(baseCenter, to: location)
    let maxDistance = bounds.width / 2 - knobSize / 2
    
    if distance <= maxDistance {
      knobView.center = location
    } else {
      let angle = angleFrom(baseCenter, to: location)
      knobView.center = CGPoint(
        x: baseCenter.x + cos(angle) * maxDistance,
        y: baseCenter.y + sin(angle) * maxDistance
      )
    }
    
    let normalizedX = (knobView.center.x - baseCenter.x) / maxDistance
    let normalizedY = (knobView.center.y - baseCenter.y) / maxDistance
    
    delegate?.joystickDidMove(x: normalizedX, y: normalizedY)
  }
  
  private func returnToCenter() {
    UIView.animate(withDuration: 0.2) {
      self.knobView.center = self.baseCenter
    }
    delegate?.joystickDidRelease()
  }
  
  private func distanceFrom(_ point1: CGPoint, to point2: CGPoint) -> CGFloat {
    return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
  }
  
  private func angleFrom(_ point1: CGPoint, to point2: CGPoint) -> CGFloat {
    return atan2(point2.y - point1.y, point2.x - point1.x)
  }
}
