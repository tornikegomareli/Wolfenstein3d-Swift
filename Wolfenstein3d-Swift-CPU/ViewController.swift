import UIKit
import CoreMotion

// MARK: - Game Engine

class Wolf3DEngine {
    // Map dimensions
    let mapWidth = 24
    let mapHeight = 24
    
    // Screen dimensions - use lower resolution for better performance
    let screenWidth = 820
    let screenHeight = 740
    
    // Player state
    var playerX: Double = 22.0
    var playerY: Double = 12.0
    var playerDirX: Double = -1.0
    var playerDirY: Double = 0.0
    var planeX: Double = 0.0
    var planeY: Double = 0.66
    
    // Movement and rotation speed
    let moveSpeed: Double = 0.1
    let rotSpeed: Double = 0.05
    
    // Frame buffer
    var frameBuffer: UnsafeMutablePointer<UInt32>
    var context: CGContext!
    
    // Simple map (1 = wall, 0 = empty)
    let worldMap: [[Int]] = [
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
        [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1],
        [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    ]
    
    init() {
        frameBuffer = UnsafeMutablePointer<UInt32>.allocate(capacity: screenWidth * screenHeight)
        
        // Create bitmap context
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        context = CGContext(data: frameBuffer,
                           width: screenWidth,
                           height: screenHeight,
                           bitsPerComponent: 8,
                           bytesPerRow: screenWidth * 4,
                           space: colorSpace,
                           bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    }
    
    deinit {
        frameBuffer.deallocate()
    }
    
    // MARK: - Rendering
    
    func render() -> UIImage? {
        // Clear screen with floor and ceiling
        let halfHeight = screenHeight / 2
        for y in 0..<halfHeight {
            // Ceiling
            let ceilingColor: UInt32 = 0xFF404040
            let floorColor: UInt32 = 0xFF808080
            let offset = y * screenWidth
            let floorOffset = (screenHeight - 1 - y) * screenWidth
            
            for x in 0..<screenWidth {
                frameBuffer[offset + x] = ceilingColor
                frameBuffer[floorOffset + x] = floorColor
            }
        }
        
        // Raycasting
        for x in 0..<screenWidth {
            // Calculate ray position and direction
            let cameraX = 2.0 * Double(x) / Double(screenWidth) - 1.0
            let rayDirX = playerDirX + planeX * cameraX
            let rayDirY = playerDirY + planeY * cameraX
            
            // Which box of the map we're in
            var mapX = Int(playerX)
            var mapY = Int(playerY)
            
            // Length of ray from current position to next x or y grid line
            var sideDistX: Double
            var sideDistY: Double
            
            // Calculate step and initial sideDist
            let deltaDistX = rayDirX == 0 ? 1e30 : abs(1.0 / rayDirX)
            let deltaDistY = rayDirY == 0 ? 1e30 : abs(1.0 / rayDirY)
            var perpWallDist: Double
            
            // Calculate step direction and initial sideDist
            var stepX: Int
            var stepY: Int
            
            var hit = 0
            var side = 0 // NS or EW wall hit?
            
            if rayDirX < 0 {
                stepX = -1
                sideDistX = (playerX - Double(mapX)) * deltaDistX
            } else {
                stepX = 1
                sideDistX = (Double(mapX) + 1.0 - playerX) * deltaDistX
            }
            
            if rayDirY < 0 {
                stepY = -1
                sideDistY = (playerY - Double(mapY)) * deltaDistY
            } else {
                stepY = 1
                sideDistY = (Double(mapY) + 1.0 - playerY) * deltaDistY
            }
            
            // Perform DDA
            while hit == 0 {
                // Jump to next map square, either in x or y direction
                if sideDistX < sideDistY {
                    sideDistX += deltaDistX
                    mapX += stepX
                    side = 0
                } else {
                    sideDistY += deltaDistY
                    mapY += stepY
                    side = 1
                }
                
                // Check if ray has hit a wall
                if mapX >= 0 && mapX < mapWidth && mapY >= 0 && mapY < mapHeight {
                    if worldMap[mapX][mapY] > 0 {
                        hit = 1
                    }
                } else {
                    break // Out of bounds
                }
            }
            
            // Calculate perpendicular distance
            if side == 0 {
                perpWallDist = (Double(mapX) - playerX + Double(1 - stepX) / 2.0) / rayDirX
            } else {
                perpWallDist = (Double(mapY) - playerY + Double(1 - stepY) / 2.0) / rayDirY
            }
            
            // Calculate height of line to draw on screen
            let lineHeight = Int(Double(screenHeight) / perpWallDist)
            
            // Calculate lowest and highest pixel to fill in current stripe
            var drawStart = -lineHeight / 2 + screenHeight / 2
            if drawStart < 0 { drawStart = 0 }
            
            var drawEnd = lineHeight / 2 + screenHeight / 2
            if drawEnd >= screenHeight { drawEnd = screenHeight - 1 }
            
            // Choose wall color based on wall type
            var color: UInt32
            switch worldMap[mapX][mapY] {
            case 1: color = 0xFFFF0000  // Red
            case 2: color = 0xFF00FF00  // Green
            case 3: color = 0xFF0000FF  // Blue
            case 4: color = 0xFFFFFFFF  // White
            case 5: color = 0xFFFFFF00  // Yellow
            default: color = 0xFFFF00FF // Purple
            }
            
            // Make walls darker if they're on the Y side
            if side == 1 {
                color = (color >> 1) & 0xFF7F7F7F
            }
            
            // Draw the vertical line
            for y in drawStart..<drawEnd {
                frameBuffer[y * screenWidth + x] = color
            }
        }
        
        // Create image from context
        guard let cgImage = context.makeImage() else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Player Movement
    
    func move(forward: Double, strafe: Double) {
        // Forward/backward movement
        let moveX = playerDirX * forward * moveSpeed
        let moveY = playerDirY * forward * moveSpeed
        
        // Strafe movement (perpendicular to view direction)
        let strafeX = -playerDirY * strafe * moveSpeed
        let strafeY = playerDirX * strafe * moveSpeed
        
        // Combined movement
        let newX = playerX + moveX + strafeX
        let newY = playerY + moveY + strafeY
        
        // Collision detection
        if worldMap[Int(newX)][Int(playerY)] == 0 {
            playerX = newX
        }
        if worldMap[Int(playerX)][Int(newY)] == 0 {
            playerY = newY
        }
    }
    
    func rotate(angle: Double) {
        let oldDirX = playerDirX
        playerDirX = playerDirX * cos(angle) - playerDirY * sin(angle)
        playerDirY = oldDirX * sin(angle) + playerDirY * cos(angle)
        
        let oldPlaneX = planeX
        planeX = planeX * cos(angle) - planeY * sin(angle)
        planeY = oldPlaneX * sin(angle) + planeY * cos(angle)
    }
}

// MARK: - Joystick View

class JoystickView: UIView {
    var knobView: UIView!
    var onMove: ((CGFloat, CGFloat) -> Void)?
    
    private let knobSize: CGFloat = 60
    private var baseCenter: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        layer.cornerRadius = bounds.width / 2
        
        // Create knob
        knobView = UIView(frame: CGRect(x: 0, y: 0, width: knobSize, height: knobSize))
        knobView.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        knobView.layer.cornerRadius = knobSize / 2
        knobView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        addSubview(knobView)
        
        baseCenter = knobView.center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches.first)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches.first)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Return knob to center
        UIView.animate(withDuration: 0.2) {
            self.knobView.center = self.baseCenter
        }
        onMove?(0, 0)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Return knob to center
        UIView.animate(withDuration: 0.2) {
            self.knobView.center = self.baseCenter
        }
        onMove?(0, 0)
    }
    
    private func handleTouch(_ touch: UITouch?) {
        guard let touch = touch else { return }
        
        let location = touch.location(in: self)
        let distance = sqrt(pow(location.x - baseCenter.x, 2) + pow(location.y - baseCenter.y, 2))
        let maxDistance = bounds.width / 2 - knobSize / 2
        
        if distance <= maxDistance {
            knobView.center = location
        } else {
            let angle = atan2(location.y - baseCenter.y, location.x - baseCenter.x)
            knobView.center = CGPoint(
                x: baseCenter.x + cos(angle) * maxDistance,
                y: baseCenter.y + sin(angle) * maxDistance
            )
        }
        
        // Calculate normalized values (-1 to 1)
        let normalizedX = (knobView.center.x - baseCenter.x) / maxDistance
        let normalizedY = (knobView.center.y - baseCenter.y) / maxDistance
        
        onMove?(normalizedX, normalizedY)
    }
}

// MARK: - View Controller

class ViewController: UIViewController {
    var engine: Wolf3DEngine!
    var imageView: UIImageView!
    var displayLink: CADisplayLink!
    var joystick: JoystickView!
    var motionManager: CMMotionManager!
    
    var moveX: CGFloat = 0
    var moveY: CGFloat = 0
    var lastRotationY: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Force landscape orientation
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        // Setup engine
        engine = Wolf3DEngine()
        
        // Setup image view
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        
        // Add debug label
        let debugLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 30))
        debugLabel.textColor = .white
        debugLabel.text = "Wolfenstein 3D Raycaster"
        debugLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(debugLabel)
        
        // Hide status bar
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup controls after view is fully laid out
        setupJoystick()
        setupGyroscope()
        
        // Start render loop
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
        
        // Update safe area layout
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func setupJoystick() {
        let joystickSize: CGFloat = 150
        joystick = JoystickView(frame: CGRect(x: 50, y: view.bounds.height - joystickSize - 50,
                                              width: joystickSize, height: joystickSize))
        
        joystick.onMove = { [weak self] x, y in
            self?.moveX = x
            self?.moveY = y
        }
        
        view.addSubview(joystick)
    }
    
    func setupGyroscope() {
        motionManager = CMMotionManager()
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates()
        }
    }
    
    @objc func update() {
        // Handle joystick movement (forward/back and strafe)
        if abs(moveX) > 0.1 || abs(moveY) > 0.1 {
            engine.move(forward: Double(-moveY), strafe: Double(moveX))
        }
        
        // Handle gyroscope rotation for landscape mode
        if let deviceMotion = motionManager.deviceMotion {
            // In landscape, we use yaw for left/right rotation
            let currentRotationY = deviceMotion.attitude.yaw
            let deltaRotation = currentRotationY - lastRotationY
            
            // Only rotate if there's significant movement
            if abs(deltaRotation) > 0.01 {
                engine.rotate(angle: deltaRotation * 2.0)
            }
            
            lastRotationY = currentRotationY
        }
        
        // Render frame
        if let image = engine.render() {
            imageView.image = image
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        motionManager?.stopDeviceMotionUpdates()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.all]
    }
    
    deinit {
        displayLink?.invalidate()
        motionManager?.stopDeviceMotionUpdates()
    }
}
