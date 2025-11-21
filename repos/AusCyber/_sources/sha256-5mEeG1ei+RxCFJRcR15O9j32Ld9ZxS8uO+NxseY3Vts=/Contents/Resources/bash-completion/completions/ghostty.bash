_ghostty() {

  # -o nospace requires we add back a space when a completion is finished
  # and not part of a --key= completion
  _add_spaces() {
    for idx in "${!COMPREPLY[@]}"; do
      [ -n "${COMPREPLY[idx]}" ] && COMPREPLY[idx]="${COMPREPLY[idx]} ";
    done
  }

  _fonts() {
    local IFS=$'\n'
    mapfile -t COMPREPLY < <( compgen -P '"' -S '"' -W "$($ghostty +list-fonts | grep '^[A-Z]' )" -- "$cur")
  }

  _themes() {
    local IFS=$'\n'
    mapfile -t COMPREPLY < <( compgen -P '"' -S '"' -W "$($ghostty +list-themes | sed -E 's/^(.*) \(.*$/\1/')" -- "$cur")
  }

  _files() {
    mapfile -t COMPREPLY < <( compgen -o filenames -f -- "$cur" )
    for i in "${!COMPREPLY[@]}"; do
      if [[ -d "${COMPREPLY[i]}" ]]; then
        COMPREPLY[i]="${COMPREPLY[i]}/";
      fi
      if [[ -f "${COMPREPLY[i]}" ]]; then
        COMPREPLY[i]="${COMPREPLY[i]} ";
      fi
    done
  }

  _dirs() {
    mapfile -t COMPREPLY < <( compgen -o dirnames -d -- "$cur" )
    for i in "${!COMPREPLY[@]}"; do
      if [[ -d "${COMPREPLY[i]}" ]]; then
        COMPREPLY[i]="${COMPREPLY[i]}/";
      fi
    done
    if [[ "${#COMPREPLY[@]}" == 0 && -d "$cur" ]]; then
      COMPREPLY=( "$cur " )
    fi
  }

  _handle_config() {
    local config="--help"
    config+=" --version"
    config+=" --font-family="
    config+=" --font-family-bold="
    config+=" --font-family-italic="
    config+=" --font-family-bold-italic="
    config+=" --font-style="
    config+=" --font-style-bold="
    config+=" --font-style-italic="
    config+=" --font-style-bold-italic="
    config+=" --font-synthetic-style="
    config+=" --font-feature="
    config+=" --font-size="
    config+=" --font-variation="
    config+=" --font-variation-bold="
    config+=" --font-variation-italic="
    config+=" --font-variation-bold-italic="
    config+=" --font-codepoint-map="
    config+=" --clipboard-codepoint-map="
    config+=" '--font-thicken '"
    config+=" --font-thicken-strength="
    config+=" --font-shaping-break="
    config+=" --alpha-blending="
    config+=" --adjust-cell-width="
    config+=" --adjust-cell-height="
    config+=" --adjust-font-baseline="
    config+=" --adjust-underline-position="
    config+=" --adjust-underline-thickness="
    config+=" --adjust-strikethrough-position="
    config+=" --adjust-strikethrough-thickness="
    config+=" --adjust-overline-position="
    config+=" --adjust-overline-thickness="
    config+=" --adjust-cursor-thickness="
    config+=" --adjust-cursor-height="
    config+=" --adjust-box-thickness="
    config+=" --adjust-icon-height="
    config+=" --grapheme-width-method="
    config+=" --freetype-load-flags="
    config+=" --theme="
    config+=" --background="
    config+=" --foreground="
    config+=" --background-image="
    config+=" --background-image-opacity="
    config+=" --background-image-position="
    config+=" --background-image-fit="
    config+=" '--background-image-repeat '"
    config+=" --selection-foreground="
    config+=" --selection-background="
    config+=" '--selection-clear-on-typing '"
    config+=" '--selection-clear-on-copy '"
    config+=" --minimum-contrast="
    config+=" --palette="
    config+=" --cursor-color="
    config+=" --cursor-opacity="
    config+=" --cursor-style="
    config+=" '--cursor-style-blink '"
    config+=" --cursor-text="
    config+=" '--cursor-click-to-move '"
    config+=" '--mouse-hide-while-typing '"
    config+=" --scroll-to-bottom="
    config+=" --mouse-shift-capture="
    config+=" '--mouse-reporting '"
    config+=" --mouse-scroll-multiplier="
    config+=" --background-opacity="
    config+=" '--background-opacity-cells '"
    config+=" --background-blur="
    config+=" --unfocused-split-opacity="
    config+=" --unfocused-split-fill="
    config+=" --split-divider-color="
    config+=" --command="
    config+=" --initial-command="
    config+=" --notify-on-command-finish="
    config+=" --notify-on-command-finish-action="
    config+=" --notify-on-command-finish-after="
    config+=" --env="
    config+=" --input="
    config+=" '--wait-after-command '"
    config+=" --abnormal-command-exit-runtime="
    config+=" --scrollback-limit="
    config+=" --scrollbar="
    config+=" --link="
    config+=" '--link-url '"
    config+=" --link-previews="
    config+=" '--maximize '"
    config+=" '--fullscreen '"
    config+=" --title="
    config+=" --class="
    config+=" --x11-instance-name="
    config+=" --working-directory="
    config+=" --keybind="
    config+=" --window-padding-x="
    config+=" --window-padding-y="
    config+=" '--window-padding-balance '"
    config+=" --window-padding-color="
    config+=" '--window-vsync '"
    config+=" '--window-inherit-working-directory '"
    config+=" '--window-inherit-font-size '"
    config+=" --window-decoration="
    config+=" --window-title-font-family="
    config+=" --window-subtitle="
    config+=" --window-theme="
    config+=" --window-colorspace="
    config+=" --window-height="
    config+=" --window-width="
    config+=" --window-position-x="
    config+=" --window-position-y="
    config+=" --window-save-state="
    config+=" '--window-step-resize '"
    config+=" --window-new-tab-position="
    config+=" --window-show-tab-bar="
    config+=" --window-titlebar-background="
    config+=" --window-titlebar-foreground="
    config+=" --resize-overlay="
    config+=" --resize-overlay-position="
    config+=" --resize-overlay-duration="
    config+=" '--focus-follows-mouse '"
    config+=" --clipboard-read="
    config+=" --clipboard-write="
    config+=" '--clipboard-trim-trailing-spaces '"
    config+=" '--clipboard-paste-protection '"
    config+=" '--clipboard-paste-bracketed-safe '"
    config+=" '--title-report '"
    config+=" --image-storage-limit="
    config+=" --copy-on-select="
    config+=" --right-click-action="
    config+=" --click-repeat-interval="
    config+=" --config-file="
    config+=" '--config-default-files '"
    config+=" --confirm-close-surface="
    config+=" '--quit-after-last-window-closed '"
    config+=" --quit-after-last-window-closed-delay="
    config+=" '--initial-window '"
    config+=" --undo-timeout="
    config+=" --quick-terminal-position="
    config+=" --quick-terminal-size="
    config+=" --gtk-quick-terminal-layer="
    config+=" --gtk-quick-terminal-namespace="
    config+=" --quick-terminal-screen="
    config+=" --quick-terminal-animation-duration="
    config+=" '--quick-terminal-autohide '"
    config+=" --quick-terminal-space-behavior="
    config+=" --quick-terminal-keyboard-interactivity="
    config+=" --shell-integration="
    config+=" --shell-integration-features="
    config+=" --command-palette-entry="
    config+=" --osc-color-report-format="
    config+=" '--vt-kam-allowed '"
    config+=" --custom-shader="
    config+=" --custom-shader-animation="
    config+=" --bell-features="
    config+=" --bell-audio-path="
    config+=" --bell-audio-volume="
    config+=" --app-notifications="
    config+=" --macos-non-native-fullscreen="
    config+=" --macos-window-buttons="
    config+=" --macos-titlebar-style="
    config+=" --macos-titlebar-proxy-icon="
    config+=" --macos-dock-drop-behavior="
    config+=" --macos-option-as-alt="
    config+=" '--macos-window-shadow '"
    config+=" --macos-hidden="
    config+=" '--macos-auto-secure-input '"
    config+=" '--macos-secure-input-indication '"
    config+=" --macos-icon="
    config+=" --macos-custom-icon="
    config+=" --macos-icon-frame="
    config+=" --macos-icon-ghost-color="
    config+=" --macos-icon-screen-color="
    config+=" --macos-shortcuts="
    config+=" --linux-cgroup="
    config+=" --linux-cgroup-memory-limit="
    config+=" --linux-cgroup-processes-limit="
    config+=" '--linux-cgroup-hard-fail '"
    config+=" '--gtk-opengl-debug '"
    config+=" --gtk-single-instance="
    config+=" '--gtk-titlebar '"
    config+=" --gtk-tabs-location="
    config+=" '--gtk-titlebar-hide-when-maximized '"
    config+=" --gtk-toolbar-style="
    config+=" --gtk-titlebar-style="
    config+=" '--gtk-wide-tabs '"
    config+=" --gtk-custom-css="
    config+=" '--desktop-notifications '"
    config+=" --bold-color="
    config+=" --faint-opacity="
    config+=" --term="
    config+=" --enquiry-response="
    config+=" --async-backend="
    config+=" --auto-update="
    config+=" --auto-update-channel="

    case "$prev" in
      --font-family) _fonts ;;
      --font-family-bold) _fonts ;;
      --font-family-italic) _fonts ;;
      --font-family-bold-italic) _fonts ;;
      --font-style) return ;;
      --font-style-bold) return ;;
      --font-style-italic) return ;;
      --font-style-bold-italic) return ;;
      --font-synthetic-style) mapfile -t COMPREPLY < <( compgen -W "bold no-bold italic no-italic bold-italic no-bold-italic" -- "$cur" ); _add_spaces ;;
      --font-feature) return ;;
      --font-size) return ;;
      --font-variation) return ;;
      --font-variation-bold) return ;;
      --font-variation-italic) return ;;
      --font-variation-bold-italic) return ;;
      --font-codepoint-map) return ;;
      --clipboard-codepoint-map) return ;;
      --font-thicken) return ;;
      --font-thicken-strength) return ;;
      --font-shaping-break) mapfile -t COMPREPLY < <( compgen -W "cursor no-cursor" -- "$cur" ); _add_spaces ;;
      --alpha-blending) mapfile -t COMPREPLY < <( compgen -W "native linear linear-corrected" -- "$cur" ); _add_spaces ;;
      --adjust-cell-width) return ;;
      --adjust-cell-height) return ;;
      --adjust-font-baseline) return ;;
      --adjust-underline-position) return ;;
      --adjust-underline-thickness) return ;;
      --adjust-strikethrough-position) return ;;
      --adjust-strikethrough-thickness) return ;;
      --adjust-overline-position) return ;;
      --adjust-overline-thickness) return ;;
      --adjust-cursor-thickness) return ;;
      --adjust-cursor-height) return ;;
      --adjust-box-thickness) return ;;
      --adjust-icon-height) return ;;
      --grapheme-width-method) mapfile -t COMPREPLY < <( compgen -W "legacy unicode" -- "$cur" ); _add_spaces ;;
      --freetype-load-flags) mapfile -t COMPREPLY < <( compgen -W "hinting no-hinting force-autohint no-force-autohint monochrome no-monochrome autohint no-autohint light no-light" -- "$cur" ); _add_spaces ;;
      --theme) _themes ;;
      --background) return ;;
      --foreground) return ;;
      --background-image) return ;;
      --background-image-opacity) return ;;
      --background-image-position) mapfile -t COMPREPLY < <( compgen -W "top-left top-center top-right center-left center-center center-right bottom-left bottom-center bottom-right center" -- "$cur" ); _add_spaces ;;
      --background-image-fit) mapfile -t COMPREPLY < <( compgen -W "contain cover stretch none" -- "$cur" ); _add_spaces ;;
      --background-image-repeat) return ;;
      --selection-foreground) return ;;
      --selection-background) return ;;
      --selection-clear-on-typing) return ;;
      --selection-clear-on-copy) return ;;
      --minimum-contrast) return ;;
      --palette) return ;;
      --cursor-color) return ;;
      --cursor-opacity) return ;;
      --cursor-style) mapfile -t COMPREPLY < <( compgen -W "bar block underline block_hollow" -- "$cur" ); _add_spaces ;;
      --cursor-style-blink) return ;;
      --cursor-text) return ;;
      --cursor-click-to-move) return ;;
      --mouse-hide-while-typing) return ;;
      --scroll-to-bottom) mapfile -t COMPREPLY < <( compgen -W "keystroke no-keystroke output no-output" -- "$cur" ); _add_spaces ;;
      --mouse-shift-capture) mapfile -t COMPREPLY < <( compgen -W "false true always never" -- "$cur" ); _add_spaces ;;
      --mouse-reporting) return ;;
      --mouse-scroll-multiplier) return ;;
      --background-opacity) return ;;
      --background-opacity-cells) return ;;
      --background-blur) return ;;
      --unfocused-split-opacity) return ;;
      --unfocused-split-fill) return ;;
      --split-divider-color) return ;;
      --command) return ;;
      --initial-command) return ;;
      --notify-on-command-finish) mapfile -t COMPREPLY < <( compgen -W "never unfocused always" -- "$cur" ); _add_spaces ;;
      --notify-on-command-finish-action) mapfile -t COMPREPLY < <( compgen -W "bell no-bell notify no-notify" -- "$cur" ); _add_spaces ;;
      --notify-on-command-finish-after) return ;;
      --env) return ;;
      --input) return ;;
      --wait-after-command) return ;;
      --abnormal-command-exit-runtime) return ;;
      --scrollback-limit) return ;;
      --scrollbar) mapfile -t COMPREPLY < <( compgen -W "system never" -- "$cur" ); _add_spaces ;;
      --link) return ;;
      --link-url) return ;;
      --link-previews) mapfile -t COMPREPLY < <( compgen -W "false true osc8" -- "$cur" ); _add_spaces ;;
      --maximize) return ;;
      --fullscreen) return ;;
      --title) return ;;
      --class) return ;;
      --x11-instance-name) return ;;
      --working-directory) _dirs ;;
      --keybind) return ;;
      --window-padding-x) return ;;
      --window-padding-y) return ;;
      --window-padding-balance) return ;;
      --window-padding-color) mapfile -t COMPREPLY < <( compgen -W "background extend extend-always" -- "$cur" ); _add_spaces ;;
      --window-vsync) return ;;
      --window-inherit-working-directory) return ;;
      --window-inherit-font-size) return ;;
      --window-decoration) mapfile -t COMPREPLY < <( compgen -W "auto client server none" -- "$cur" ); _add_spaces ;;
      --window-title-font-family) return ;;
      --window-subtitle) mapfile -t COMPREPLY < <( compgen -W "false working-directory" -- "$cur" ); _add_spaces ;;
      --window-theme) mapfile -t COMPREPLY < <( compgen -W "auto system light dark ghostty" -- "$cur" ); _add_spaces ;;
      --window-colorspace) mapfile -t COMPREPLY < <( compgen -W "srgb display-p3" -- "$cur" ); _add_spaces ;;
      --window-height) return ;;
      --window-width) return ;;
      --window-position-x) return ;;
      --window-position-y) return ;;
      --window-save-state) mapfile -t COMPREPLY < <( compgen -W "default never always" -- "$cur" ); _add_spaces ;;
      --window-step-resize) return ;;
      --window-new-tab-position) mapfile -t COMPREPLY < <( compgen -W "current end" -- "$cur" ); _add_spaces ;;
      --window-show-tab-bar) mapfile -t COMPREPLY < <( compgen -W "always auto never" -- "$cur" ); _add_spaces ;;
      --window-titlebar-background) return ;;
      --window-titlebar-foreground) return ;;
      --resize-overlay) mapfile -t COMPREPLY < <( compgen -W "always never after-first" -- "$cur" ); _add_spaces ;;
      --resize-overlay-position) mapfile -t COMPREPLY < <( compgen -W "center top-left top-center top-right bottom-left bottom-center bottom-right" -- "$cur" ); _add_spaces ;;
      --resize-overlay-duration) return ;;
      --focus-follows-mouse) return ;;
      --clipboard-read) mapfile -t COMPREPLY < <( compgen -W "allow deny ask" -- "$cur" ); _add_spaces ;;
      --clipboard-write) mapfile -t COMPREPLY < <( compgen -W "allow deny ask" -- "$cur" ); _add_spaces ;;
      --clipboard-trim-trailing-spaces) return ;;
      --clipboard-paste-protection) return ;;
      --clipboard-paste-bracketed-safe) return ;;
      --title-report) return ;;
      --image-storage-limit) return ;;
      --copy-on-select) mapfile -t COMPREPLY < <( compgen -W "false true clipboard" -- "$cur" ); _add_spaces ;;
      --right-click-action) mapfile -t COMPREPLY < <( compgen -W "ignore paste copy copy-or-paste context-menu" -- "$cur" ); _add_spaces ;;
      --click-repeat-interval) return ;;
      --config-file) _files ;;
      --config-default-files) return ;;
      --confirm-close-surface) mapfile -t COMPREPLY < <( compgen -W "false true always" -- "$cur" ); _add_spaces ;;
      --quit-after-last-window-closed) return ;;
      --quit-after-last-window-closed-delay) return ;;
      --initial-window) return ;;
      --undo-timeout) return ;;
      --quick-terminal-position) mapfile -t COMPREPLY < <( compgen -W "top bottom left right center" -- "$cur" ); _add_spaces ;;
      --quick-terminal-size) return ;;
      --gtk-quick-terminal-layer) mapfile -t COMPREPLY < <( compgen -W "overlay top bottom background" -- "$cur" ); _add_spaces ;;
      --gtk-quick-terminal-namespace) return ;;
      --quick-terminal-screen) mapfile -t COMPREPLY < <( compgen -W "main mouse macos-menu-bar" -- "$cur" ); _add_spaces ;;
      --quick-terminal-animation-duration) return ;;
      --quick-terminal-autohide) return ;;
      --quick-terminal-space-behavior) mapfile -t COMPREPLY < <( compgen -W "remain move" -- "$cur" ); _add_spaces ;;
      --quick-terminal-keyboard-interactivity) mapfile -t COMPREPLY < <( compgen -W "none on-demand exclusive" -- "$cur" ); _add_spaces ;;
      --shell-integration) mapfile -t COMPREPLY < <( compgen -W "none detect bash elvish fish zsh" -- "$cur" ); _add_spaces ;;
      --shell-integration-features) mapfile -t COMPREPLY < <( compgen -W "cursor no-cursor sudo no-sudo title no-title ssh-env no-ssh-env ssh-terminfo no-ssh-terminfo path no-path" -- "$cur" ); _add_spaces ;;
      --command-palette-entry) return ;;
      --osc-color-report-format) mapfile -t COMPREPLY < <( compgen -W "none 8-bit 16-bit" -- "$cur" ); _add_spaces ;;
      --vt-kam-allowed) return ;;
      --custom-shader) _files ;;
      --custom-shader-animation) mapfile -t COMPREPLY < <( compgen -W "false true always" -- "$cur" ); _add_spaces ;;
      --bell-features) mapfile -t COMPREPLY < <( compgen -W "system no-system audio no-audio attention no-attention title no-title border no-border" -- "$cur" ); _add_spaces ;;
      --bell-audio-path) return ;;
      --bell-audio-volume) return ;;
      --app-notifications) mapfile -t COMPREPLY < <( compgen -W "clipboard-copy no-clipboard-copy config-reload no-config-reload" -- "$cur" ); _add_spaces ;;
      --macos-non-native-fullscreen) mapfile -t COMPREPLY < <( compgen -W "false true visible-menu padded-notch" -- "$cur" ); _add_spaces ;;
      --macos-window-buttons) mapfile -t COMPREPLY < <( compgen -W "visible hidden" -- "$cur" ); _add_spaces ;;
      --macos-titlebar-style) mapfile -t COMPREPLY < <( compgen -W "native transparent tabs hidden" -- "$cur" ); _add_spaces ;;
      --macos-titlebar-proxy-icon) mapfile -t COMPREPLY < <( compgen -W "visible hidden" -- "$cur" ); _add_spaces ;;
      --macos-dock-drop-behavior) mapfile -t COMPREPLY < <( compgen -W "new-tab window" -- "$cur" ); _add_spaces ;;
      --macos-option-as-alt) return ;;
      --macos-window-shadow) return ;;
      --macos-hidden) mapfile -t COMPREPLY < <( compgen -W "never always" -- "$cur" ); _add_spaces ;;
      --macos-auto-secure-input) return ;;
      --macos-secure-input-indication) return ;;
      --macos-icon) mapfile -t COMPREPLY < <( compgen -W "official blueprint chalkboard microchip glass holographic paper retro xray custom custom-style" -- "$cur" ); _add_spaces ;;
      --macos-custom-icon) return ;;
      --macos-icon-frame) mapfile -t COMPREPLY < <( compgen -W "aluminum beige plastic chrome" -- "$cur" ); _add_spaces ;;
      --macos-icon-ghost-color) return ;;
      --macos-icon-screen-color) return ;;
      --macos-shortcuts) mapfile -t COMPREPLY < <( compgen -W "allow deny ask" -- "$cur" ); _add_spaces ;;
      --linux-cgroup) mapfile -t COMPREPLY < <( compgen -W "never always single-instance" -- "$cur" ); _add_spaces ;;
      --linux-cgroup-memory-limit) return ;;
      --linux-cgroup-processes-limit) return ;;
      --linux-cgroup-hard-fail) return ;;
      --gtk-opengl-debug) return ;;
      --gtk-single-instance) mapfile -t COMPREPLY < <( compgen -W "false true detect" -- "$cur" ); _add_spaces ;;
      --gtk-titlebar) return ;;
      --gtk-tabs-location) mapfile -t COMPREPLY < <( compgen -W "top bottom" -- "$cur" ); _add_spaces ;;
      --gtk-titlebar-hide-when-maximized) return ;;
      --gtk-toolbar-style) mapfile -t COMPREPLY < <( compgen -W "flat raised raised-border" -- "$cur" ); _add_spaces ;;
      --gtk-titlebar-style) mapfile -t COMPREPLY < <( compgen -W "native tabs" -- "$cur" ); _add_spaces ;;
      --gtk-wide-tabs) return ;;
      --gtk-custom-css) _files ;;
      --desktop-notifications) return ;;
      --bold-color) return ;;
      --faint-opacity) return ;;
      --term) return ;;
      --enquiry-response) return ;;
      --async-backend) mapfile -t COMPREPLY < <( compgen -W "auto epoll io_uring" -- "$cur" ); _add_spaces ;;
      --auto-update) return ;;
      --auto-update-channel) return ;;
      *) mapfile -t COMPREPLY < <( compgen -W "$config" -- "$cur" ) ;;
    esac

    return 0
  }

  _handle_actions() {
    local list_fonts="--family= --style= '--bold ' '--italic ' --help"
    local list_keybinds="'--default ' '--docs ' '--plain ' --help"
    local list_themes="'--path ' '--plain ' --color= --help"
    local list_colors="'--plain ' --help"
    local list_actions="'--docs ' --help"
    local ssh_cache="'--clear ' --add= --remove= --host= --expire-days= --help"
    local show_config="'--default ' '--changes-only ' '--docs ' --help"
    local validate_config="--config-file= --help"
    local show_face="--cp= --string= --style= --presentation= --help"
    local new_window="--class= --help"

    case "${COMP_WORDS[1]}" in
      +list-fonts)
        case $prev in
          --family) return;;
          --style) return;;
          --bold) return ;;
          --italic) return ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$list_fonts" -- "$cur" ) ;;
        esac
      ;;
      +list-keybinds)
        case $prev in
          --default) return ;;
          --docs) return ;;
          --plain) return ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$list_keybinds" -- "$cur" ) ;;
        esac
      ;;
      +list-themes)
        case $prev in
          --path) return ;;
          --plain) return ;;
          --color) mapfile -t COMPREPLY < <( compgen -W "all dark light" -- "$cur" ); _add_spaces ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$list_themes" -- "$cur" ) ;;
        esac
      ;;
      +list-colors)
        case $prev in
          --plain) return ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$list_colors" -- "$cur" ) ;;
        esac
      ;;
      +list-actions)
        case $prev in
          --docs) return ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$list_actions" -- "$cur" ) ;;
        esac
      ;;
      +ssh-cache)
        case $prev in
          --clear) return ;;
          --add) return;;
          --remove) return;;
          --host) return;;
          --expire-days) return;;
          *) mapfile -t COMPREPLY < <( compgen -W "$ssh_cache" -- "$cur" ) ;;
        esac
      ;;
      +show-config)
        case $prev in
          --default) return ;;
          --changes-only) return ;;
          --docs) return ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$show_config" -- "$cur" ) ;;
        esac
      ;;
      +validate-config)
        case $prev in
          --config-file) return ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$validate_config" -- "$cur" ) ;;
        esac
      ;;
      +show-face)
        case $prev in
          --cp) return;;
          --string) return;;
          --style) mapfile -t COMPREPLY < <( compgen -W "regular bold italic bold_italic" -- "$cur" ); _add_spaces ;;
          --presentation) mapfile -t COMPREPLY < <( compgen -W "text emoji" -- "$cur" ); _add_spaces ;;
          *) mapfile -t COMPREPLY < <( compgen -W "$show_face" -- "$cur" ) ;;
        esac
      ;;
      +new-window)
        case $prev in
          --class) return;;
          *) mapfile -t COMPREPLY < <( compgen -W "$new_window" -- "$cur" ) ;;
        esac
      ;;
      *) mapfile -t COMPREPLY < <( compgen -W "--help" -- "$cur" ) ;;
    esac

    return 0
  }

  # begin main logic
  local topLevel="-e"
  topLevel+=" --help"
  topLevel+=" --version"
  topLevel+=" +list-fonts"
  topLevel+=" +list-keybinds"
  topLevel+=" +list-themes"
  topLevel+=" +list-colors"
  topLevel+=" +list-actions"
  topLevel+=" +ssh-cache"
  topLevel+=" +edit-config"
  topLevel+=" +show-config"
  topLevel+=" +validate-config"
  topLevel+=" +show-face"
  topLevel+=" +crash-report"
  topLevel+=" +boo"
  topLevel+=" +new-window"

  local cur=""; local prev=""; local prevWasEq=false; COMPREPLY=()
  local ghostty="$1"

  # script assumes default COMP_WORDBREAKS of roughly $' \t\n"\'><=;|&(:'
  # if = is missing this script will degrade to matching on keys only.
  # eg: --key=
  # this can be improved if needed see: https://github.com/ghostty-org/ghostty/discussions/2994

  if [ "$2" = "=" ]; then cur=""
  else                    cur="$2"
  fi

  if [ "$3" = "=" ]; then prev="${COMP_WORDS[COMP_CWORD-2]}"; prevWasEq=true;
  else                    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # current completion is double quoted add a space so the curor progresses
  if [[ "$2" == \"*\" ]]; then
    COMPREPLY=( "$cur " );
    return;
  fi

  case "$COMP_CWORD" in
    1)
      case "${COMP_WORDS[1]}" in
        -e | --help | --version) return 0 ;;
        --*) _handle_config ;;
        *) mapfile -t COMPREPLY < <( compgen -W "${topLevel}" -- "$cur" ); _add_spaces ;;
      esac
      ;;
    *)
      case "$prev" in
        -e | --help | --version) return 0 ;;
        *)
          if [[ "=" != "${COMP_WORDS[COMP_CWORD]}" && $prevWasEq != true ]]; then
            # must be completing with a space after the key eg: '--<key> '
            # clear out prev so we don't run any of the key specific completions
            prev=""
          fi

          case "${COMP_WORDS[1]}" in
            --*) _handle_config ;;
            +*) _handle_actions ;;
          esac
          ;;
      esac
      ;;
  esac

  return 0
}

complete -o nospace -o bashdefault -F _ghostty ghostty
