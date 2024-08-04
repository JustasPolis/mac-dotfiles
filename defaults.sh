defaults write -g NSWindowShouldDragOnGesture YES
defaults write -g ApplePersistence -bool no
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
defaults write -g EnableStandardClickToShowDesktop NO

defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "show hidden files by default"
defaults write com.apple.Finder AppleShowAllFiles -bool false

echo "expand save dialog by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# echo "show the ~/Library folder in Finder"
chflags nohidden ~/Library

echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

defaults write com.apple.finder QuitMenuItem -bool true

defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write com.apple.dock launchanim -bool false

defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Move & Resize\033Left' '@~^$\U2190'
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Move & Resize\033Right' '@~^$\U2192'
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Move & Resize\033Bottom Right' '@~^$k'
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Move & Resize\033Bottom Left' '@~^$j'
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Move & Resize\033Top Right' '@~^$l'
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Move & Resize\033Top Left' '@~^$h'
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Fill' '@~^$\U0046'
defaults write -g NSUserKeyEquivalents -dict-add '\033Window\033Center' '@~^$\U0043'
