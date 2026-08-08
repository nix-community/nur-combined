{
  lib,
  stdenv,
  pkgs,
  forkgram-desktop,
  swift6-jen20,
}:
let
  inherit (import ../../../private.nix { inherit pkgs; }) v3overridegcc;
  # On-device Translation needs Swift 6 on Darwin. nixpkgs sets
  # DESKTOP_APP_DISABLE_SWIFT6 because stock nixpkgs has no Swift 6; we have
  # swift6-jen20 (6.2.4). Feature is Apple-only (lib_translate enable_language(Swift)).
  enableSwift6 = stdenv.hostPlatform.isDarwin;
in
forkgram-desktop.overrideAttrs (old: {
  unwrapped = v3overridegcc (
    old.unwrapped.overrideAttrs (
      old2:
      {
        # see https://github.com/Layerex/telegram-desktop-patches
        patches =
          (forkgram-desktop.unwrapped.patches or [ ])
          ++ [
            ./0001-forkgramPatches.patch
          ]
          ++ lib.optionals enableSwift6 [
            # Point apple Swift runtime helper at Nix Swift instead of Xcode.
            ./nix-swift-runtime.patch
          ];

        nativeBuildInputs = (old2.nativeBuildInputs or [ ]) ++ lib.optionals enableSwift6 [ swift6-jen20 ];

        # Drop nixpkgs' hard-disable, then set explicitly for this platform.
        cmakeFlags =
          builtins.filter (f: !(lib.hasInfix "DESKTOP_APP_DISABLE_SWIFT6" (toString f))) (
            old2.cmakeFlags or [ ]
          )
          ++ [
            (lib.cmakeBool "DESKTOP_APP_DISABLE_SWIFT6" (!enableSwift6))
          ]
          ++ lib.optionals enableSwift6 [
            (lib.cmakeFeature "CMAKE_Swift_COMPILER" "${swift6-jen20}/bin/swiftc")
          ];
      }
      // lib.optionalAttrs enableSwift6 {
        # Assembled swift package puts Darwin dylibs in $out/lib (see stdlib packaging).
        NIX_SWIFT_LIB_DIR = "${swift6-jen20}/lib";
        SWIFTC = "${swift6-jen20}/bin/swiftc";
      }
    )
  );
})
