#!/bin/bash

# Run script for Wolfenstein3d-Swift-CPU

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running Wolfenstein3d-Swift-CPU...${NC}"

# Default values
CONFIGURATION="Debug"
SCHEME="Wolfenstein3d-Swift-CPU"
PROJECT_PATH="src/Wolfenstein3d-Swift-CPU.xcodeproj"
DEVICE="iPhone 15"
BUILD_FIRST=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --device)
            DEVICE="$2"
            shift 2
            ;;
        --no-build)
            BUILD_FIRST=false
            shift
            ;;
        --list-devices)
            echo -e "${BLUE}Available devices:${NC}"
            xcrun simctl list devices | grep -E "iPhone|iPad"
            exit 0
            ;;
        -h|--help)
            echo "Usage: ./run.sh [options]"
            echo "Options:"
            echo "  --release         Run in Release configuration"
            echo "  --device NAME     Specify simulator device (default: iPhone 15)"
            echo "  --no-build        Skip building before running"
            echo "  --list-devices    List available simulator devices"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. Please install Xcode or Xcode Command Line Tools.${NC}"
    exit 1
fi

# Build first if requested
if [ "$BUILD_FIRST" = true ]; then
    echo -e "${YELLOW}Building project first...${NC}"
    ./build.sh $([ "$CONFIGURATION" = "Release" ] && echo "--release")
    if [ $? -ne 0 ]; then
        echo -e "${RED}Build failed! Cannot run.${NC}"
        exit 1
    fi
fi

# Check if simulator is booted
echo -e "${YELLOW}Checking simulator status...${NC}"
BOOTED_DEVICE=$(xcrun simctl list devices | grep "$DEVICE" | grep "Booted" | head -1)

if [ -z "$BOOTED_DEVICE" ]; then
    echo -e "${YELLOW}Booting $DEVICE simulator...${NC}"
    # Find the device identifier
    DEVICE_ID=$(xcrun simctl list devices | grep "$DEVICE" | head -1 | grep -o '\([A-F0-9-]*\)' | tr -d '()')
    
    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}Error: Device '$DEVICE' not found.${NC}"
        echo -e "${YELLOW}Use --list-devices to see available devices.${NC}"
        exit 1
    fi
    
    xcrun simctl boot "$DEVICE_ID"
    sleep 3
fi

# Run on simulator
echo -e "${YELLOW}Running on $DEVICE...${NC}"
xcodebuild -project "$PROJECT_PATH" \
           -scheme "$SCHEME" \
           -configuration "$CONFIGURATION" \
           -destination "platform=iOS Simulator,name=$DEVICE" \
           -derivedDataPath build \
           run

# Check run result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}App launched successfully!${NC}"
else
    echo -e "${RED}Failed to launch app!${NC}"
    exit 1
fi