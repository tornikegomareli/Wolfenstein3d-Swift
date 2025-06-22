#!/bin/bash

# Build script for all targets

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building Wolfenstein3d Multi-Platform Project...${NC}"

# Default values
CONFIGURATION="Debug"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. Please install Xcode.${NC}"
    exit 1
fi

# Clean if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Cleaning all builds...${NC}"
    xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj -alltargets clean
fi

# Build Engine framework
echo -e "${YELLOW}Building Engine framework...${NC}"
xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj \
           -scheme Engine \
           -configuration "$CONFIGURATION" \
           build

if [ $? -ne 0 ]; then
    echo -e "${RED}Engine framework build failed!${NC}"
    exit 1
fi
echo -e "${GREEN}Engine framework build succeeded!${NC}"

# Build iOS app
echo -e "${YELLOW}Building iOS app...${NC}"
xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj \
           -scheme Wolfenstein3d-Swift-CPU \
           -sdk iphonesimulator \
           -configuration "$CONFIGURATION" \
           build

if [ $? -ne 0 ]; then
    echo -e "${RED}iOS app build failed!${NC}"
    exit 1
fi
echo -e "${GREEN}iOS app build succeeded!${NC}"

# Build macOS app
echo -e "${YELLOW}Building macOS app...${NC}"
xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj \
           -scheme Wolfenstein3d-Macintosh \
           -configuration "$CONFIGURATION" \
           build

if [ $? -ne 0 ]; then
    echo -e "${RED}macOS app build failed!${NC}"
    exit 1
fi
echo -e "${GREEN}macOS app build succeeded!${NC}"

echo -e "${GREEN}All builds completed successfully!${NC}"
echo -e "${GREEN}To run:${NC}"
echo -e "${GREEN}  iOS:   ./run-ios.sh${NC}"
echo -e "${GREEN}  macOS: ./run-macos.sh${NC}"