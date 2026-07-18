{
  pkgs,
  telegram-desktop,
}:
let
  inherit (import ../../../private.nix { inherit pkgs; }) v3overridegcc;
in
telegram-desktop.overrideAttrs (old: {
  unwrapped = v3overridegcc (
    old.unwrapped.overrideAttrs (_old2: {
      # see https://github.com/Layerex/telegram-desktop-patches
      patches = (telegram-desktop.unwrapped.patches or [ ]) ++ [
        ./0001-telegramPatches.patch
      ];
    })
  );
})
