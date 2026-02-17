#!/bin/bash

# Define app name
APP_NAME="SimpleHabitTracker"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

# Build the project
echo "Building ${APP_NAME}..."
swift build -c release

# Create the .app structure
echo "Creating ${APP_BUNDLE}..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy the binary
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "${APP_NAME}.app created successfully!"

# Install to /Applications
INSTALL_PATH="/Applications/${APP_BUNDLE}"
echo "Installing to ${INSTALL_PATH}..."

# Remove existing app if it exists
if [ -d "${INSTALL_PATH}" ]; then
    rm -rf "${INSTALL_PATH}"
fi

# Move new app to Applications
mv "${APP_BUNDLE}" "/Applications/"

echo "Installation complete!"
echo "You can now find ${APP_NAME} in your Applications folder."

