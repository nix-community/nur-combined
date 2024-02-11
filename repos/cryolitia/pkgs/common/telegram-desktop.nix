{ lib
, telegram-desktop
, qtwayland
}:

telegram-desktop.override {
  qtwayland = qtwayland.overrideAttrs (oldAttrs: rec {
    patches = oldAttrs.patches ++ [
      # https://gitlab.archlinux.org/archlinux/packaging/packages/telegram-desktop/-/issues/1
      ./telegram-01.patch
    ];
  });
}
