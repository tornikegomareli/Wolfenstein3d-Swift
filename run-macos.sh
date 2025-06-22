#!/bin/bash

# Run script for macOS app

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running Wolfenstein3d macOS app...${NC}"

# Build
echo -e "${YELLOW}Building...${NC}"
xcodebuild -project Wolfenstein3d-Swift-CPU.xcodeproj \
           -scheme Wolfenstein3d-Macintosh \
           -configuration Debug \
           clean build

# Check build result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build succeeded!${NC}"
    
    # Find and run the app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Wolfenstein3d-Macintosh.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo -e "${GREEN}Launching app from: $APP_PATH${NC}"
        open "$APP_PATH"
    else
        echo -e "${RED}Could not find built app${NC}"
        exit 1
    fi
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi