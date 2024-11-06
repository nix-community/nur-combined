{
  lib,
  materialgram,
  telegram-desktop,
}:
let
  unwrapped = materialgram.unwrapped.overrideAttrs (old: {
    # Patches obtained from https://github.com/Layerex/telegram-desktop-patches
    patches = (old.patches or [ ]) ++ [
      ./disable-invite-peeking-restrictions.patch
      ./disable-saving-restrictions.patch
      ./disable-sponspored-messages.patch
      ./disable-stories.patch
    ];

    # Disable account limit
    postPatch =
      (old.postPatch or "")
      + ''
        sed -i -E \
          "s/static constexpr auto kMaxAccounts =.*/static constexpr auto kMaxAccounts = 255;/g" \
          Telegram/SourceFiles/main/main_domain.h
        sed -i -E \
          "s/static constexpr auto kPremiumMaxAccounts =.*/static constexpr auto kPremiumMaxAccounts = 255;/g" \
          Telegram/SourceFiles/main/main_domain.h
      '';

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
