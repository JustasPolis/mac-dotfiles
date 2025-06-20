defaults write -g NSWindowShouldDragOnGesture YES
defaults write -g ApplePersistence -bool no
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
defaults write -g EnableStandardClickToShowDesktop NO

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
echo "Finder: show all filename extensions"

echo "show hidden files by default"
defaults write com.apple.Finder AppleShowAllFiles -bool true

echo "expand save dialog by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

echo "show the ~/Library folder in Finder"
chflags nohidden ~/Library

echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write com.apple.dock launchanim -bool false
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.dock autohide-delay           -float 0
defaults write com.apple.dock autohide-time-modifier  -float 0
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode  -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write -g ApplePressAndHoldEnabled  -bool false

