{
  sources,
  lib,
  telegram-desktop,
  ...
}:
telegram-desktop.overrideAttrs (old: {
  # Patches obtained from https://github.com/Layerex/telegram-desktop-patches
  patches = (old.patches or [ ]) ++ [
    (sources.telegram-desktop-patches.src + "/0001-Disable-sponsored-messages.patch")
    (sources.telegram-desktop-patches.src + "/0002-Disable-saving-restrictions.patch")
    (sources.telegram-desktop-patches.src + "/0003-Disable-invite-peeking-restrictions.patch")
    (sources.telegram-desktop-patches.src + "/0005-Option-to-disable-stories.patch")
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
})
