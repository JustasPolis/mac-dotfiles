#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
app_support_dir="$HOME/Library/Application Support/Google"

if [[ -n "${ANDROID_STUDIO_CONFIG_DIR:-}" ]]; then
  config_dir="$ANDROID_STUDIO_CONFIG_DIR"
else
  config_dir="$(find "$app_support_dir" -maxdepth 1 -type d -name 'AndroidStudio*' -print 2>/dev/null | sort -V | tail -n 1)"
fi

if [[ -z "${config_dir:-}" ]]; then
  echo "Launch Android Studio once first, or set ANDROID_STUDIO_CONFIG_DIR."
  exit 1
fi

jar_bin="${ANDROID_STUDIO_JAR_BIN:-/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/jar}"
if [[ ! -x "$jar_bin" ]]; then
  jar_bin="$(command -v jar)"
fi

theme_plugin_dir="$config_dir/plugins"
theme_jar="$theme_plugin_dir/intellij-xcode-dark-theme.jar"
completion_plugin_dir="$theme_plugin_dir/no-completion-ads/lib"

mkdir -p "$config_dir/colors" "$config_dir/options" "$theme_plugin_dir" "$completion_plugin_dir"
mkdir -p "$HOME/Library/Caches/Google/${config_dir:t}/whatsnew"

cp "$script_dir/themes/xcode-dark/Xcode-Dark.xml" "$config_dir/colors/Xcode 27 Default Dark.icls"
cp "$script_dir/config/idea.properties" "$config_dir/idea.properties"
cp "$script_dir/config/options/editor.xml" "$config_dir/options/editor.xml"
cp "$script_dir/config/options/laf.xml" "$config_dir/options/laf.xml"
cp "$script_dir/config/options/ui.lnf.xml" "$config_dir/options/ui.lnf.xml"

"$jar_bin" --create --file "$theme_jar" -C "$script_dir/themes/xcode-dark" .
cp "$script_dir/plugins/no-completion-ads/lib/no-completion-ads.jar" "$completion_plugin_dir/no-completion-ads.jar"

echo "Android Studio customizations installed in: $config_dir"
echo "Restart Android Studio to load the theme and plugins."
