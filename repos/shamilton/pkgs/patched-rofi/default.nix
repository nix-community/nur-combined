{ rofi-unwrapped, nixosVersion }:
rofi-unwrapped.overrideAttrs (old: {
  patches = (old.patches or []) ++ [
    (
      if nixosVersion != "master" then ./add-nix-dirs-app-desktop-search.patch else ./add-nix-dirs-app-desktop-search.patch
    )
  ];
})
