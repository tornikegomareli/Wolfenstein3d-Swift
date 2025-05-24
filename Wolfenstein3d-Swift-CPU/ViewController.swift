import UIKit
import CoreMotion

// MARK: - Game Engine

class Wolf3DEngine {
    // Map dimensions
    let mapWidth = 24
    let mapHeight = 24

    // Screen dimensions - TRY LOWERING THESE FIRST FOR PERFORMANCE
    // For example: screenWidth = 320, screenHeight = 240
    let screenWidth = 820 // User's original value
    let screenHeight = 740 // User's original value

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
        context = CGContext(
            data: frameBuffer,
            width: screenWidth,
            height: screenHeight,
            bitsPerComponent: 8,
            bytesPerRow: screenWidth * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
    }

    deinit {
        frameBuffer.deallocate()
    }

    // MARK: - Rendering

    func render() -> UIImage? {
        // Define ceiling and floor colors (you can make these properties of the class if they don't change)
        let ceilingColor: UInt32 = 0xFF404040 // Dark Gray for ceiling
        let floorColor: UInt32 = 0xFF808080   // Lighter Gray for floor

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
            var perpWallDist: Double = 0

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
                // Ensure mapX and mapY are within bounds before accessing worldMap
                if mapX >= 0 && mapX < mapWidth && mapY >= 0 && mapY < mapHeight {
                    if worldMap[mapX][mapY] > 0 {
                        hit = 1
                    }
                } else {
                    // Ray is out of bounds, effectively hit an infinitely distant wall
                    // or simply stop. For this example, we'll break.
                    // You might want to assign a very large perpWallDist here
                    // or handle it as an error/edge case.
                    hit = 1 // Treat as hit to stop DDA
                    perpWallDist = 1e30 // Make it very far
                    // No break here, let perpWallDist calculation proceed
                }
            }

            // Calculate perpendicular distance
            if hit == 1 && perpWallDist != 1e30 { // Ensure perpWallDist wasn't set to infinite due to out of bounds
                 if side == 0 {
                     perpWallDist = (Double(mapX) - playerX + Double(1 - stepX) / 2.0) / rayDirX
                 } else {
                     perpWallDist = (Double(mapY) - playerY + Double(1 - stepY) / 2.0) / rayDirY
                 }
            } else if perpWallDist != 1e30 { // If hit was 0 (should not happen if loop terminates correctly) or already infinite
                perpWallDist = 1e30 // Default to very far if something went wrong or out of bounds
            }


            // Calculate height of line to draw on screen
            // Avoid division by zero or very small perpWallDist
            let lineHeight: Int
            if perpWallDist > 0.0001 {
                lineHeight = Int(Double(screenHeight) / perpWallDist)
            } else {
                lineHeight = screenHeight // Draw full height line if wall is extremely close or dist is 0
            }

            // Calculate lowest and highest pixel to fill in current stripe
            var drawStart = -lineHeight / 2 + screenHeight / 2
            if drawStart < 0 { drawStart = 0 }

            var drawEnd = lineHeight / 2 + screenHeight / 2
            if drawEnd >= screenHeight { drawEnd = screenHeight - 1 }

            // Choose wall color based on wall type
            var wallColor: UInt32
            // Check bounds again before accessing worldMap, especially if ray went out of bounds
            if mapX >= 0 && mapX < mapWidth && mapY >= 0 && mapY < mapHeight {
                switch worldMap[mapX][mapY] {
                case 1: wallColor = 0xFFFF0000  // Red
                case 2: wallColor = 0xFF00FF00  // Green
                case 3: wallColor = 0xFF0000FF  // Blue
                case 4: wallColor = 0xFFFFFFFF  // White
                case 5: wallColor = 0xFFFFFF00  // Yellow
                default: wallColor = 0x00000000 // Black or transparent if it's an "empty" space that was hit (e.g. out of bounds)
                }
            } else {
                wallColor = 0x000000FF // Default color for out-of-bounds, e.g., blue void
            }


            // Make walls darker if they're on the Y side (east/west walls)
            if side == 1 {
                wallColor = (wallColor >> 1) & 0xFF7F7F7F // Halve brightness, preserve alpha
            }

            // --- Optimized Drawing Logic for the column ---
            var y = 0
            // Draw ceiling for this column
            while y < drawStart {
                if y < screenHeight { // Ensure y is within screen bounds
                    frameBuffer[y * screenWidth + x] = ceilingColor
                }
                y += 1
            }

            // Draw the wall stripe for this column
            while y < drawEnd {
                if y >= 0 && y < screenHeight { // Ensure y is within screen bounds
                     frameBuffer[y * screenWidth + x] = wallColor
                }
                y += 1
            }

            // Draw floor for this column
            while y < screenHeight {
                if y >= 0 { // Ensure y is within screen bounds (already checked by loop condition y < screenHeight)
                    frameBuffer[y * screenWidth + x] = floorColor
                }
                y += 1
            }
            // --- End of optimized drawing logic ---
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
        let strafeX = planeX * strafe * moveSpeed // Corrected: Strafe with plane vector
        let strafeY = planeY * strafe * moveSpeed // Corrected: Strafe with plane vector

        // Combined movement
        let newPlayerX = playerX + moveX + strafeX
        let newPlayerY = playerY + moveY + strafeY
        
        // Collision detection
        // Check X-movement
        if Int(newPlayerX) >= 0 && Int(newPlayerX) < mapWidth && Int(playerY) >= 0 && Int(playerY) < mapHeight {
            if worldMap[Int(newPlayerX)][Int(playerY)] == 0 {
                playerX = newPlayerX
            }
        }
        // Check Y-movement (using the potentially updated playerX for sliding)
        if Int(playerX) >= 0 && Int(playerX) < mapWidth && Int(newPlayerY) >= 0 && Int(newPlayerY) < mapHeight {
            if worldMap[Int(playerX)][Int(newPlayerY)] == 0 {
                playerY = newPlayerY
            }
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

// MARK: - Joystick View (Unchanged from your original)

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


// MARK: - View Controller (Unchanged from your original, but check gyroscope usage)

class ViewController: UIViewController {
    var engine: Wolf3DEngine!
    var imageView: UIImageView!
    var displayLink: CADisplayLink!
    var joystick: JoystickView!
    var motionManager: CMMotionManager!

    var moveX: CGFloat = 0
    var moveY: CGFloat = 0
    var lastAttitudeYaw: Double? // Using optional to handle initial state

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Force landscape orientation
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { error in
                print("Error requesting geometry update: \(error)")
            }
        } else {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }


        // Setup engine
        engine = Wolf3DEngine()

        // Setup image view
        imageView = UIImageView(frame: view.bounds) // Will be adjusted in viewDidLayoutSubviews
        imageView.contentMode = .scaleAspectFill // Or .scaleToFill
        imageView.backgroundColor = .black // Should be covered by engine output
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)

        // Add debug label
        let debugLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 30))
        debugLabel.textColor = .white
        debugLabel.text = "Wolfenstein 3D Raycaster"
        debugLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(debugLabel)

        // Hide status bar (handled by prefersStatusBarHidden)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Adjust image view frame if needed, e.g., to match engine's aspect ratio
        // For now, full bounds is fine with scaleAspectFill
        imageView.frame = view.bounds

        // Setup controls here if their layout depends on final view bounds
        if joystick == nil { // Setup only once
             setupJoystick()
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Ensure joystick is set up if viewDidLayoutSubviews wasn't called or joystick needs recreation
        if joystick == nil || joystick.superview == nil {
            setupJoystick() // Ensure joystick is added to view hierarchy
        }

        setupGyroscope()

        // Start render loop
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(update))
            displayLink.add(to: .current, forMode: .default)
        }

        // Safe area insets might not be what you want for a full-screen game
        // additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: -view.safeAreaInsets.left, bottom: 0, right: -view.safeAreaInsets.right)
    }

    func setupJoystick() {
        // Remove existing joystick if any, to prevent duplicates
        joystick?.removeFromSuperview()

        let joystickSize: CGFloat = 150
        // Ensure view.bounds is valid here. viewDidLayoutSubviews is safer for bounds-dependent frames.
        let yPos = view.bounds.height - joystickSize - (view.safeAreaInsets.bottom + 20) // Adjust 20 for padding
        let xPos = view.safeAreaInsets.left + 50

        joystick = JoystickView(frame: CGRect(x: xPos,
                                              y: yPos,
                                              width: joystickSize, height: joystickSize))

        joystick.onMove = { [weak self] x, y in
            self?.moveX = x
            self?.moveY = y // Joystick Y is typically screen Y, so up is negative.
                            // Engine `move` expects forward as positive.
        }
        view.addSubview(joystick)
    }

    func setupGyroscope() {
        motionManager = CMMotionManager()

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // Match screen refresh rate
            // Using CMAttitudeReferenceFrame.xArbitraryZVertical is often best for landscape games
            // to get a stable yaw that doesn't drift as much with pitch/roll.
            // You might need to experiment with different reference frames.
            motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion else { return }

                let currentYaw = motion.attitude.yaw

                if self.lastAttitudeYaw == nil {
                    self.lastAttitudeYaw = currentYaw // Initialize on first update
                    return
                }

                var deltaRotation = currentYaw - self.lastAttitudeYaw!

                // Handle wrap-around from -pi to pi (or vice versa)
                if deltaRotation > .pi {
                    deltaRotation -= 2 * .pi
                } else if deltaRotation < -.pi {
                    deltaRotation += 2 * .pi
                }

                // Apply a sensitivity factor and threshold
                let rotationSensitivity = 1.5 // Adjust this factor as needed
                let rotationThreshold = 0.005 // Adjust this threshold

                if abs(deltaRotation) > rotationThreshold {
                    // In landscape, yaw directly maps to left/right rotation.
                    // Engine's rotate function expects angle where positive is typically counter-clockwise.
                    // Depending on how yaw is reported and how you want it to feel, you might need to invert deltaRotation.
                    self.engine.rotate(angle: deltaRotation * rotationSensitivity)
                }
                self.lastAttitudeYaw = currentYaw
            }
        }
    }


    @objc func update() {
        // Handle joystick movement (forward/back and strafe)
        // Joystick: Y-axis is typically screen coordinates (up is negative).
        // Engine: 'forward' positive is forward. So, invert joystick Y.
        // Joystick: X-axis is screen coordinates (right is positive).
        // Engine: 'strafe' positive could be right.
        if abs(moveX) > 0.1 || abs(moveY) > 0.1 {
            engine.move(forward: Double(-moveY), strafe: Double(moveX))
        }

        // Gyroscope rotation is handled by the CMMotionManager handler now.

        // Render frame
        if let image = engine.render() {
            imageView.image = image
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        displayLink = nil
        motionManager?.stopDeviceMotionUpdates()
        lastAttitudeYaw = nil // Reset for next appearance
    }

    override var shouldAutorotate: Bool {
        return true // Or false if you strictly control it
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight // Or .landscapeLeft
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // This helps in making edge swipes less likely to interrupt the game.
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.all]
    }

    deinit {
        displayLink?.invalidate()
        motionManager?.stopDeviceMotionUpdates()
    }
}
