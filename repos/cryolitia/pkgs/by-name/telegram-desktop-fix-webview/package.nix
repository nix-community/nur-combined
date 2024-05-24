{ telegram-desktop, qt6Packages }:

(telegram-desktop.override {
  qtwayland = qt6Packages.qtwayland.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches ++ [
      # https://gitlab.archlinux.org/archlinux/packaging/packages/telegram-desktop/-/issues/1
      ./telegram-01.patch
    ];
  });
}).overrideAttrs
  (oldAttrs: {
    meta = oldAttrs.meta // {
      description = "Telegram desktop with patch https://gitlab.archlinux.org/archlinux/packaging/packages/telegram-desktop/-/issues/1";
      # error: Package ‘jasper-4.2.2’ in /nix/store/dfwrffdwrrybch69gawdj9qd1rnp7mnk-source/pkgs/by-name/ja/jasper/package.nix:60 is marked as broken, refusing to evaluate
      badPlatforms = [ "aarch64-linux" ];
    };
  })
