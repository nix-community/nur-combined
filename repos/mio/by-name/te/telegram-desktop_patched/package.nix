{
  lib,
  stdenv,
  pkgs,
  telegram-desktop,
  swift,
}:
let
  inherit (import ../../../private.nix { inherit pkgs; }) v3overridegcc;
  # On-device Translation needs Swift 6 on Darwin. nixpkgs sets
  # DESKTOP_APP_DISABLE_SWIFT6 because stock nixpkgs has no Swift 6; we have
  # swift (6.4.0). Feature is Apple-only (lib_translate enable_language(Swift)).
  # Upstream's telegram_apple_swift_runtime.cmake finds swift-stdlib-tool next
  # to CMAKE_Swift_COMPILER, so no extra patching is needed.
  enableSwift6 = stdenv.hostPlatform.isDarwin;
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

      nativeBuildInputs = (old2.nativeBuildInputs or [ ]) ++ lib.optionals enableSwift6 [ swift ];

      # Drop nixpkgs' hard-disable, then set explicitly for this platform.
      cmakeFlags =
        builtins.filter (f: !(lib.hasInfix "DESKTOP_APP_DISABLE_SWIFT6" (toString f))) (
          old2.cmakeFlags or [ ]
        )
        ++ [
          (lib.cmakeBool "DESKTOP_APP_DISABLE_SWIFT6" (!enableSwift6))
        ]
        ++ lib.optionals enableSwift6 [
          (lib.cmakeFeature "CMAKE_Swift_COMPILER" "${swift}/bin/swiftc")
        ];
    })
  );
})
