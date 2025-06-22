#!/bin/bash

# Build script for Wolfenstein3d-Swift-CPU

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building Wolfenstein3d-Swift-CPU...${NC}"

# Default values
CONFIGURATION="Debug"
SCHEME="Wolfenstein3d-Swift-CPU"
PROJECT_PATH="Wolfenstein3d-Swift-CPU.xcodeproj"

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
    echo -e "${RED}Error: xcodebuild not found. Please install Xcode or Xcode Command Line Tools.${NC}"
    exit 1
fi

# Clean if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Cleaning build...${NC}"
    xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" clean
fi

# Build the project
echo -e "${YELLOW}Building with configuration: $CONFIGURATION${NC}"
xcodebuild -project "$PROJECT_PATH" \
           -scheme "$SCHEME" \
           -configuration "$CONFIGURATION" \
           -derivedDataPath build \
           build

# Check build result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build succeeded!${NC}"
    echo -e "${GREEN}Build output is in: build/${NC}"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi