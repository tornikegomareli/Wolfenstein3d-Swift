# Wolfenstein 3D Swift (Multi-Platform)

A multi-platform Wolfenstein 3D raycasting engine implemented in Swift, supporting both iOS and macOS.

## Features

- Pure CPU rendering (no GPU acceleration)
- Multi-platform support (iOS and macOS)
- Texture mapping support
- Platform-specific controls:
  - iOS: Touch-based controls (joystick + look)
  - macOS: Keyboard (WASD) and mouse controls
- Optimized column-based rendering
- Real-time FPS display

## Architecture

The project is structured with a clean separation between platform-independent engine code and platform-specific implementations:

### Engine Framework
- Platform-independent game logic and rendering
- Software-based raycasting implementation
- No external dependencies

### Platform Targets
- **iOS**: Touch controls, gyroscope support
- **macOS**: Keyboard (WASD) and mouse controls

## Project Structure

```
Wolfenstein3d-Swift-CPU/
├── Engine/                        # Shared framework
│   ├── Core/                      # Game engine, renderer
│   ├── Models/                    # Game data structures
│   ├── Rendering/                 # Texture management
│   ├── Configuration/             # Game settings
│   └── Protocols/                 # Platform abstractions
├── Wolfenstein3d-Swift-CPU/       # iOS app
│   ├── Platform/                  # iOS-specific implementations
│   └── UI/                        # Touch controls
└── Wolfenstein3d-Macintosh/       # macOS app
    └── Platform/                  # macOS-specific implementations
```

## Requirements

- Xcode 15.0+
- macOS 14.0+ (for development)
- iOS 15.0+ (deployment target)
- macOS 12.0+ (deployment target)
- Swift 5.0+

## Building

### Build All Targets
```bash
# Debug build (default)
./build-all.sh

# Release build
./build-all.sh --release

# Clean and build
./build-all.sh --clean
```

### Build Specific Target
```bash
# iOS
xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj -scheme Wolfenstein3d-Swift-CPU -sdk iphonesimulator build

# macOS
xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj -scheme Wolfenstein3d-Macintosh build
```

### Using Xcode
```bash
open Wolfenstein3d-Swift-CPU.xcodeproj
```
Then select the desired scheme and build.

## Running

### iOS
```bash
# Run on default simulator (iPhone 15)
./run-ios.sh

# Run on specific device
./run-ios.sh --device "iPad Pro (12.9-inch)"
```

### macOS
```bash
./run-macos.sh
```

## Controls

### iOS
- **Left Joystick**: Movement (forward/backward/strafe)
- **Touch & Drag**: Look around
- **Gyroscope**: Tilt device to look (if available)

### macOS
- **W/A/S/D**: Movement (forward/left/backward/right)
- **Arrow Keys**: Turn left/right
- **Mouse Drag**: Look around

## Performance

The renderer is optimized for CPU performance with:
- Direct pixel buffer manipulation
- Minimal allocations in render loop
- Platform-specific display synchronization
- Column-based rendering
- Texture column caching

Target performance:
- iPhone 12+: 60 FPS at native resolution
- M1 Mac: 120+ FPS at 1920x1080

## License

This project is for educational purposes, demonstrating raycasting techniques and multi-platform Swift development.
