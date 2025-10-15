set -l commands "+list-fonts +list-keybinds +list-themes +list-colors +list-actions +ssh-cache +edit-config +show-config +validate-config +show-face +crash-report +boo +new-window"
complete -c ghostty -f
complete -c ghostty -s e -l help -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l version -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-family -r -f  -a "(ghostty +list-fonts | grep '^[A-Z]')"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-family-bold -r -f  -a "(ghostty +list-fonts | grep '^[A-Z]')"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-family-italic -r -f  -a "(ghostty +list-fonts | grep '^[A-Z]')"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-family-bold-italic -r -f  -a "(ghostty +list-fonts | grep '^[A-Z]')"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-style -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-style-bold -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-style-italic -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-style-bold-italic -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-synthetic-style -r -f -a "bold no-bold italic no-italic bold-italic no-bold-italic"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-feature -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-size -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-variation -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-variation-bold -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-variation-italic -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-variation-bold-italic -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-codepoint-map -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-thicken  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-thicken-strength -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l font-shaping-break -r -f -a "cursor no-cursor"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l alpha-blending -r -f -a "native linear linear-corrected"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-cell-width -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-cell-height -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-font-baseline -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-underline-position -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-underline-thickness -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-strikethrough-position -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-strikethrough-thickness -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-overline-position -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-overline-thickness -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-cursor-thickness -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-cursor-height -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-box-thickness -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l adjust-icon-height -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l grapheme-width-method -r -f -a "legacy unicode"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l freetype-load-flags -r -f -a "hinting no-hinting force-autohint no-force-autohint monochrome no-monochrome autohint no-autohint"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l theme -r -f -a "(ghostty +list-themes | sed -E 's/^(.*) \(.*\$/\1/')"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l foreground -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-image -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-image-opacity -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-image-position -r -f -a "top-left top-center top-right center-left center-center center-right bottom-left bottom-center bottom-right center"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-image-fit -r -f -a "contain cover stretch none"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-image-repeat  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l selection-foreground -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l selection-background -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l selection-clear-on-typing  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l selection-clear-on-copy  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l minimum-contrast -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l palette -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l cursor-color -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l cursor-opacity -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l cursor-style -r -f -a "bar block underline block_hollow"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l cursor-style-blink -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l cursor-text -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l cursor-click-to-move  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l mouse-hide-while-typing  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l scroll-to-bottom -r -f -a "keystroke no-keystroke output no-output"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l mouse-shift-capture -r -f -a "false true always never"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l mouse-scroll-multiplier -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-opacity -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-opacity-cells  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l background-blur -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l unfocused-split-opacity -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l unfocused-split-fill -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l split-divider-color -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l command -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l initial-command -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l notify-on-command-finish -r -f -a "never unfocused always"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l notify-on-command-finish-action -r -f -a "bell no-bell notify no-notify"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l notify-on-command-finish-after -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l env -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l input -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l wait-after-command  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l abnormal-command-exit-runtime -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l scrollback-limit -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l link -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l link-url  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l link-previews -r -f -a "false true osc8"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l maximize  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l fullscreen  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l title -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l class -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l x11-instance-name -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l working-directory -r -f -k -a "(__fish_complete_directories)"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l keybind -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-padding-x -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-padding-y -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-padding-balance  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-padding-color -r -f -a "background extend extend-always"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-vsync  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-inherit-working-directory  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-inherit-font-size  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-decoration -r -f -a "auto client server none"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-title-font-family -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-subtitle -r -f -a "false working-directory"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-theme -r -f -a "auto system light dark ghostty"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-colorspace -r -f -a "srgb display-p3"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-height -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-width -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-position-x -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-position-y -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-save-state -r -f -a "default never always"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-step-resize  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-new-tab-position -r -f -a "current end"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-show-tab-bar -r -f -a "always auto never"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-titlebar-background -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l window-titlebar-foreground -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l resize-overlay -r -f -a "always never after-first"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l resize-overlay-position -r -f -a "center top-left top-center top-right bottom-left bottom-center bottom-right"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l resize-overlay-duration -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l focus-follows-mouse  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l clipboard-read -r -f -a "allow deny ask"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l clipboard-write -r -f -a "allow deny ask"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l clipboard-trim-trailing-spaces  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l clipboard-paste-protection  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l clipboard-paste-bracketed-safe  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l title-report  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l image-storage-limit -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l copy-on-select -r -f -a "false true clipboard"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l right-click-action -r -f -a "ignore paste copy copy-or-paste context-menu"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l click-repeat-interval -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l config-file -r -F
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l config-default-files  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l confirm-close-surface -r -f -a "false true always"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quit-after-last-window-closed  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quit-after-last-window-closed-delay -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l initial-window  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l undo-timeout -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quick-terminal-position -r -f -a "top bottom left right center"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quick-terminal-size -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-quick-terminal-layer -r -f -a "overlay top bottom background"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-quick-terminal-namespace -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quick-terminal-screen -r -f -a "main mouse macos-menu-bar"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quick-terminal-animation-duration -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quick-terminal-autohide  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quick-terminal-space-behavior -r -f -a "remain move"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l quick-terminal-keyboard-interactivity -r -f -a "none on-demand exclusive"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l shell-integration -r -f -a "none detect bash elvish fish zsh"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l shell-integration-features -r -f -a "cursor no-cursor sudo no-sudo title no-title ssh-env no-ssh-env ssh-terminfo no-ssh-terminfo path no-path"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l command-palette-entry -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l osc-color-report-format -r -f -a "none 8-bit 16-bit"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l vt-kam-allowed  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l custom-shader -r -F
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l custom-shader-animation -r -f -a "false true always"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l bell-features -r -f -a "system no-system audio no-audio attention no-attention title no-title border no-border"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l bell-audio-path -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l bell-audio-volume -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l app-notifications -r -f -a "clipboard-copy no-clipboard-copy config-reload no-config-reload"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-non-native-fullscreen -r -f -a "false true visible-menu padded-notch"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-window-buttons -r -f -a "visible hidden"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-titlebar-style -r -f -a "native transparent tabs hidden"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-titlebar-proxy-icon -r -f -a "visible hidden"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-dock-drop-behavior -r -f -a "new-tab window"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-option-as-alt -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-window-shadow  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-hidden -r -f -a "never always"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-auto-secure-input  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-secure-input-indication  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-icon -r -f -a "official blueprint chalkboard microchip glass holographic paper retro xray custom custom-style"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-custom-icon -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-icon-frame -r -f -a "aluminum beige plastic chrome"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-icon-ghost-color -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-icon-screen-color -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l macos-shortcuts -r -f -a "allow deny ask"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l linux-cgroup -r -f -a "never always single-instance"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l linux-cgroup-memory-limit -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l linux-cgroup-processes-limit -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l linux-cgroup-hard-fail  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-opengl-debug  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-single-instance -r -f -a "false true detect"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-titlebar  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-tabs-location -r -f -a "top bottom"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-titlebar-hide-when-maximized  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-toolbar-style -r -f -a "flat raised raised-border"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-titlebar-style -r -f -a "native tabs"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-wide-tabs  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l gtk-custom-css -r -F
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l desktop-notifications  -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l bold-color -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l faint-opacity -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l term -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l enquiry-response -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l async-backend -r -f -a "auto epoll io_uring"
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l auto-update -r -f
complete -c ghostty -n "not __fish_seen_subcommand_from $commands" -l auto-update-channel -r -f
complete -c ghostty -n "string match -q -- '+*' (commandline -pt)" -f -a "+list-fonts +list-keybinds +list-themes +list-colors +list-actions +ssh-cache +edit-config +show-config +validate-config +show-face +crash-report +boo +new-window"
complete -c ghostty -n "__fish_seen_subcommand_from +list-fonts" -l family -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-fonts" -l style -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-fonts" -l bold -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-fonts" -l italic -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-keybinds" -l default -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-keybinds" -l docs -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-keybinds" -l plain -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-themes" -l path -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-themes" -l plain -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-themes" -l color -r -f -a "all dark light"
complete -c ghostty -n "__fish_seen_subcommand_from +list-colors" -l plain -f
complete -c ghostty -n "__fish_seen_subcommand_from +list-actions" -l docs -f
complete -c ghostty -n "__fish_seen_subcommand_from +ssh-cache" -l clear -f
complete -c ghostty -n "__fish_seen_subcommand_from +ssh-cache" -l add -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +ssh-cache" -l remove -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +ssh-cache" -l host -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +ssh-cache" -l expire-days -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +show-config" -l default -f
complete -c ghostty -n "__fish_seen_subcommand_from +show-config" -l changes-only -f
complete -c ghostty -n "__fish_seen_subcommand_from +show-config" -l docs -f
complete -c ghostty -n "__fish_seen_subcommand_from +validate-config" -l config-file -r -F
complete -c ghostty -n "__fish_seen_subcommand_from +show-face" -l cp -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +show-face" -l string -r -f
complete -c ghostty -n "__fish_seen_subcommand_from +show-face" -l style -r -f -a "regular bold italic bold_italic"
complete -c ghostty -n "__fish_seen_subcommand_from +show-face" -l presentation -r -f -a "text emoji"
complete -c ghostty -n "__fish_seen_subcommand_from +new-window" -l class -r -f
