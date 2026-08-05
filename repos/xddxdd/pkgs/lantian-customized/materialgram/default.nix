{
  lib,
  materialgram,
  telegram-desktop,
}:
let
  unwrapped = materialgram.unwrapped.overrideAttrs (old: {
    # Patches obtained from https://github.com/Layerex/telegram-desktop-patches
    # adapted to materialgram's fork of telegram-desktop.
    patches = (old.patches or [ ]) ++ [
      ./0001-Disable-sponsored-messages.patch
      ./0002-Disable-saving-restrictions.patch
      ./0003-Disable-invite-peeking-restrictions.patch
      ./0004-Disable-accounts-limit.patch
      ./0005-Option-to-disable-stories.patch
    ];

    meta = old.meta // {
      description = "${old.meta.description} (Without anti-features)";
      maintainers = with lib.maintainers; [ xddxdd ];
    };
  });
in
telegram-desktop.override {
  inherit (materialgram) pname;
  inherit unwrapped;
}
