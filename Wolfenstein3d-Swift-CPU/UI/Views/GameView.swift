import UIKit

class GameView: UIView {
  private var imageView: UIImageView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    backgroundColor = .black
    
    imageView = UIImageView(frame: bounds)
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .black
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(imageView)
  }
  
  func updateFrame(_ image: UIImage) {
    imageView.image = image
  }
}
