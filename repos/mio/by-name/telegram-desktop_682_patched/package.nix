{ telegram-desktop_682 }:
telegram-desktop_682.overrideAttrs (old: {
  unwrapped = (
    old.unwrapped.overrideAttrs (old2: {
      # see https://github.com/Layerex/telegram-desktop-patches
      patches = (telegram-desktop_682.unwrapped.patches or [ ]) ++ [
        ./0001-telegramPatches.patch
      ];
    })
  );
})
