# Makefile for Wolfenstein3d-Swift-CPU

.PHONY: all build run clean help open test

# Default target
all: build

# Build the project
build:
	@./build.sh

# Build in release mode
release:
	@./build.sh --release

# Run the project
run:
	@./run.sh

# Run in release mode
run-release:
	@./run.sh --release

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build/
	@xcodebuild -project src/Wolfenstein3d-Swift-CPU.xcodeproj -scheme Wolfenstein3d-Swift-CPU clean

# Open in Xcode
open:
	@open src/Wolfenstein3d-Swift-CPU.xcodeproj

# List available devices
devices:
	@./run.sh --list-devices

# Run tests (if any)
test:
	@echo "Running tests..."
	@xcodebuild -project src/Wolfenstein3d-Swift-CPU.xcodeproj \
		-scheme Wolfenstein3d-Swift-CPU \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		test

# Help
help:
	@echo "Available targets:"
	@echo "  make build       - Build the project (debug)"
	@echo "  make release     - Build the project (release)"
	@echo "  make run         - Build and run on simulator"
	@echo "  make run-release - Build and run release on simulator"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make open        - Open project in Xcode"
	@echo "  make devices     - List available simulator devices"
	@echo "  make test        - Run tests"
	@echo "  make help        - Show this help message"