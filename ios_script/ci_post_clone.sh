#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# # Log the current environment for debugging purposes (optional, can be removed in production)
# echo "Current environment variables:"
# env

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Generate code using build_runner
dart run build_runner build --delete-conflicting-outputs

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

# Create .env file from environment variables
cd $CI_PRIMARY_REPOSITORY_PATH
echo "Generating .env file..."
cat <<EOF > .env
API_BASE_URL=${API_BASE_URL}
EOF

echo ".env file created successfully."

exit 0