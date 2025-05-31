# Wolfenstein 3D Swift CPU Renderer

A pure CPU-based raycaster implementation of Wolfenstein 3D style rendering in Swift for iOS.

## Features

- Pure CPU rendering (no GPU acceleration)
- Texture mapping support
- Touch-based controls (joystick + look)
- Optimized column-based rendering
- Real-time FPS display

## Project Structure

```
.
├── src/                          # Source code
│   ├── Wolfenstein3d-Swift-CPU/  # Main app source
│   │   ├── Application/          # App lifecycle
│   │   ├── Configuration/        # Game settings
│   │   ├── Controllers/          # View controllers
│   │   ├── Engine/               # Core rendering engine
│   │   ├── Managers/             # Input and motion managers
│   │   ├── Models/               # Game models
│   │   ├── Resources/            # Maps and assets
│   │   └── UI/                   # UI components
│   └── Wolfenstein3d-Swift-CPU.xcodeproj
├── build.sh                      # Build script
├── run.sh                        # Run script
├── CLAUDE.md                     # AI assistant instructions
└── README.md                     # This file
```

## Requirements

- macOS with Xcode installed
- iOS 13.0+ deployment target
- Swift 5.0+

## Building

### Using the build script:

```bash
# Debug build (default)
./build.sh

# Release build
./build.sh --release

# Clean and build
./build.sh --clean
```

### Using Xcode:

```bash
open src/Wolfenstein3d-Swift-CPU.xcodeproj
```

Then build and run from Xcode.

## Running

### Using the run script:

```bash
# Run on default simulator (iPhone 15)
./run.sh

# Run on specific device
./run.sh --device "iPhone 14 Pro"

# List available devices
./run.sh --list-devices

# Run without building
./run.sh --no-build

# Run release build
./run.sh --release
```

## Controls

- **Left Joystick**: Move forward/backward and strafe left/right
- **Touch and Drag**: Look around (rotate view)

## Performance

The renderer is optimized for CPU performance with:
- Column-based rendering
- Texture column caching
- Pre-calculated reciprocals
- Batch pixel operations

Typical performance: 30-60 FPS on modern iOS devices
