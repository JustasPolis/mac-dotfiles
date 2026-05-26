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

# ── Extra animation kills ──────────────────────────────────
defaults write -g NSWindowResizeTime -float 0.001                                # Near-instant window resize
defaults write -g QLPanelAnimationDuration -float 0                              # Instant Quick Look open
defaults write -g NSToolbarFullScreenAnimationDuration -float 0                  # Instant fullscreen transition
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0               # Instant column browser animations
defaults write com.apple.dock expose-animation-duration -float 0.1               # Fast Mission Control animation
defaults write com.apple.dock springboard-show-duration -float 0                 # Instant Launchpad show
defaults write com.apple.dock springboard-hide-duration -float 0                 # Instant Launchpad hide
defaults write com.apple.Mail DisableReplyAnimations -bool true                  # No Mail reply animation
defaults write com.apple.Mail DisableSendAnimations -bool true                   # No Mail send animation

# ── Spotlight: exclude build dirs from indexing ────────────
# Prevents Spotlight from burning CPU indexing DerivedData/build artifacts
defaults write com.apple.spotlight orderedItems -array \
  '{"enabled" = 1;"name" = "APPLICATIONS";}' \
  '{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
  '{"enabled" = 1;"name" = "CONTACT";}' \
  '{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
  '{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
  '{"enabled" = 0;"name" = "DOCUMENTS";}' \
  '{"enabled" = 0;"name" = "DIRECTORIES";}' \
  '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
  '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
  '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
  '{"enabled" = 0;"name" = "MESSAGES";}' \
  '{"enabled" = 0;"name" = "EVENT_TODO";}' \
  '{"enabled" = 0;"name" = "BOOKMARKS";}' \
  '{"enabled" = 0;"name" = "MUSIC";}' \
  '{"enabled" = 0;"name" = "MOVIES";}' \
  '{"enabled" = 0;"name" = "FONTS";}'

# ── Telemetry & diagnostics off ────────────────────────────
defaults write com.apple.CrashReporter DialogType none                           # Don't show crash reporter dialog
defaults write com.apple.assistant.support 'Assistant Enabled' -bool false       # Disable Siri assistant
defaults write com.apple.assistant.support 'Dictation Enabled' -bool false       # Disable Dictation (kills corespeechd/localspeechrecognition usage)
defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0               # Don't auto-enable dictation
defaults write -g NSAutomaticTextCompletionEnabled -bool false                   # Disable inline autocomplete
defaults write com.apple.Siri StatusMenuVisible -bool false                      # Hide Siri from menu bar
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true      # Disable lookup suggestions
defaults write com.apple.UsageTracking CoreDonationsEnabled -bool false          # Disable usage donations to Apple
defaults write com.apple.UsageTracking UDCAutomationEnabled -bool false          # Disable automated usage data collection

# ── Misc performance ──────────────────────────────────────
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false                  # Save to local disk by default, not iCloud
defaults write com.apple.screencapture disable-shadow -bool true                 # No drop shadow on screenshots
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true     # No .DS_Store on network volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true         # No .DS_Store on USB drives
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true      # Stop "use this disk for TM?" prompts
defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true     # Auto-quit print app when done

# ── Software update off (stops softwareupdated churn) ─────
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false   # No background update checks
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false       # No background update downloads
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -int 0            # No XProtect/MRT silent installs
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -int 0        # No critical update auto-install
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ScheduleFrequency -int 0            # No scheduled update polling
defaults write com.apple.commerce AutoUpdate -bool false                                              # No App Store auto-update
defaults write com.apple.commerce AutoUpdateRestartRequired -bool false                               # No auto-restart for updates

# ── Diagnostic auto-submit off ────────────────────────────
sudo defaults write /Library/Preferences/com.apple.SubmitDiagInfo AutoSubmit -bool false              # No crash/diag auto-submit to Apple
sudo defaults write /Library/Preferences/com.apple.SubmitDiagInfo AutoSubmitVersion -int 4
sudo defaults write /Library/Preferences/com.apple.SubmitDiagInfo ThirdPartyDataSubmit -bool false    # No third-party diag sharing
sudo defaults write /Library/Preferences/com.apple.SubmitDiagInfo ThirdPartyDataSubmitVersion -int 4

