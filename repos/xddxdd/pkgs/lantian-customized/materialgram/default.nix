{
  lib,
  fetchurl,
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
      (fetchurl {
        name = "CVE-2026-107181.patch";
        url = "https://github.com/telegramdesktop/tdesktop/commit/db3405699f8fc3ae28a58d2348b7d13a43c0590a.patch";
        hash = "sha256-E9KI3AwKpCPG/Gr8GMjA1BaSwNme7v2GzWXwb5P+FRg=";
      })
    ];

    meta = old.meta // {
      description = "${old.meta.description} (Without anti-features)";
      maintainers = with lib.maintainers; [ xddxdd ];
      knownVulnerabilities = builtins.filter (issue: !(lib.hasPrefix "CVE-2026-107181:" issue)) (
        old.meta.knownVulnerabilities or [ ]
      );
    };
  });
in
(telegram-desktop.override {
  inherit (materialgram) pname;
  inherit unwrapped;
}).overrideAttrs
  (_: {
    __structuredAttrs = true;
    strictDeps = true;
  })
