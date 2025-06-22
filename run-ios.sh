#!/bin/bash

# Run script for iOS app

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running Wolfenstein3d iOS app...${NC}"

# Default simulator
SIMULATOR="iPhone 15"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            SIMULATOR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: ./run-ios.sh [--device \"Device Name\"]"
            exit 1
            ;;
    esac
done

# Build and run
echo -e "${YELLOW}Building and running on $SIMULATOR...${NC}"
xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj \
           -scheme Wolfenstein3d-Swift-CPU \
           -destination "platform=iOS Simulator,name=$SIMULATOR" \
           -configuration Debug \
           clean build | xcpretty

# Launch the app
xcrun simctl boot "$SIMULATOR" 2>/dev/null
open -a Simulator
xcrun simctl launch booted com.tornike.Wolfenstein3d-Swift-CPU

echo -e "${GREEN}App launched on $SIMULATOR${NC}"