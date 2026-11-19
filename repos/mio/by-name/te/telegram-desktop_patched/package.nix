{
  pkgs,
  telegram-desktop,
}:
let
  inherit (import ../../../private.nix { inherit pkgs; }) v3overridegcc;
in
telegram-desktop.overrideAttrs (old: {
  unwrapped = v3overridegcc (
    old.unwrapped.overrideAttrs (old2: {
      # see https://github.com/Layerex/telegram-desktop-patches
      patches = (telegram-desktop.unwrapped.patches or [ ]) ++ [
        ./0001-telegramPatches.patch
        # The 7.x list widget checks copy/select restrictions through
        # HistoryView::CopyRestrictionTypeFor; the older patch only covers
        # the legacy HistoryInner paths.
        ./0002-remove-copy-restrictions.patch
      ];
    })
  );
})
