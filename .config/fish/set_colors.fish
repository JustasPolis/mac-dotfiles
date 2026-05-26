# One-time color setup script for fish shell (mellow theme)
# Run once with: fish -c 'source ~/.config/fish/set_colors.fish'
# These are universal variables - they persist across sessions automatically.

# Mellow color palette
set -l mellow_fg           c9c7cd
set -l mellow_bg           161617
set -l mellow_black        27272a
set -l mellow_bright_black 353539
set -l mellow_red          d4b5a0
set -l mellow_bright_red   dfc2ad

set -l mellow_yellow       d4b5a0
set -l mellow_bright_yellow dfc2ad
set -l mellow_blue         968a7c
set -l mellow_bright_blue  b3a193
set -l mellow_magenta      968a7c
set -l mellow_bright_magenta b3a193
set -l mellow_cyan         968a7c
set -l mellow_bright_cyan  b3a193
set -l mellow_white        c9c7cd
set -l mellow_bright_white d4d2d8
set -l mellow_grey         7b7b80

set -U fish_color_normal           $mellow_fg
set -U fish_color_command          $mellow_magenta
set -U fish_color_keyword          $mellow_blue
set -U fish_color_quote            $mellow_magenta
set -U fish_color_redirection      $mellow_blue
set -U fish_color_end              $mellow_blue
set -U fish_color_error            $mellow_red
set -U fish_color_param            $mellow_bright_magenta
set -U fish_color_option           $mellow_yellow
set -U fish_color_comment          $mellow_grey
set -U fish_color_operator         $mellow_yellow
set -U fish_color_escape           $mellow_cyan
set -U fish_color_autosuggestion   $mellow_bright_black
set -U fish_color_cwd              $mellow_magenta
set -U fish_color_cwd_root         $mellow_red
set -U fish_color_valid_path       $mellow_bright_blue
set -U fish_color_selection        --background=$mellow_bright_black
set -U fish_color_search_match     $mellow_bg --bold --background=$mellow_yellow
set -U fish_pager_color_prefix                 $mellow_blue --bold
set -U fish_pager_color_completion             $mellow_fg
set -U fish_pager_color_description            $mellow_grey
set -U fish_pager_color_progress               $mellow_blue --bold
set -U fish_pager_color_secondary_description  $mellow_bright_black
set -U fish_pager_color_selected_background    --background=$mellow_black
set -U fish_pager_color_selected_prefix        $mellow_blue --bold
set -U fish_pager_color_selected_completion    $mellow_bright_white
set -U fish_pager_color_selected_description   $mellow_grey

echo "Fish colors set successfully! This only needs to run once."
