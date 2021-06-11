{ rofi-unwrapped }:
rofi-unwrapped.overrideAttrs (old: {
  patches = (old.patches or []) ++ [ ./add-nix-dirs-app-desktop-search.patch ];
})
