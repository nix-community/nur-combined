{
  pkgs,
  materialgram,
}:
let
  inherit (import ../../../private.nix { inherit pkgs; }) v3overridegcc;
in
materialgram.overrideAttrs (old: {
  unwrapped = v3overridegcc (
    old.unwrapped.overrideAttrs (_old2: {
      # see https://github.com/Layerex/telegram-desktop-patches
      patches = (materialgram.unwrapped.patches or [ ]) ++ [
        ./0001-materialgramPatches.patch
      ];
    })
  );
})
