{
  lib,
  telegram-desktop,
  fetchFromGitHub,
  zbar,
  pango,
  tlottie,
  wallet-engine,
  swift,
  writeShellApplication,
  nix-update,
}:

(telegram-desktop.override {
  pname = "forkgram-desktop";
  unwrapped = telegram-desktop.unwrapped.overrideAttrs (
    finalAttrs: previousAttrs: {
      pname = "forkgram-desktop-unwrapped";
      version = "7.4.5";

      src = fetchFromGitHub {
        owner = "forkgram";
        repo = "tdesktop";
        tag = "v${finalAttrs.version}";
        fetchSubmodules = true;
        hash = "sha256-SlWUhMKRuvF7Dp6pQvMFml55+dXVb2H1qZzCP3Eg1Ak=";
      };

      buildInputs = previousAttrs.buildInputs ++ [
        zbar
        pango
        tlottie
        wallet-engine
      ];

      # nixpkgs' swift 6.4.0 chain does not build on aarch64-darwin at this
      # pin: swift-collections 1.7.6 fails in its own postInstall because its
      # dylibs were linked without header padding. Build the macOS app without
      # the Swift 6 on-device translation provider instead of pulling in a
      # toolchain that cannot be built; it is the only Swift code tdesktop
      # compiles on macOS (Telegram/lib_translate).
      cmakeFlags = previousAttrs.cmakeFlags ++ [
        (lib.cmakeBool "DESKTOP_APP_DISABLE_SWIFT6" true)
      ];
      nativeBuildInputs = lib.remove swift previousAttrs.nativeBuildInputs;

      postPatch = (previousAttrs.postPatch or "") + ''
        pushd cmake
        patch -p1 < ../patches/cmake_zbar.patch
        popd
        sed -i 's/cmark_parser_set_allocation_abort_flag/\/\/cmark_parser_set_allocation_abort_flag/g' Telegram/SourceFiles/iv/markdown/iv_markdown_parse_convert.cpp
      '';

      meta = previousAttrs.meta // {
        description = "Forkgram desktop messaging app";
        homepage = "https://github.com/forkgram/tdesktop";
        changelog = "https://github.com/forkgram/tdesktop/releases/tag/v${finalAttrs.version}";
        mainProgram = "Forkgram";
      };
    }
  );
}).overrideAttrs
  (prevAttrs: {
    passthru = (prevAttrs.passthru or { }) // {
      updateScript = writeShellApplication {
        name = "update-forkgram-desktop";
        runtimeInputs = [ nix-update ];
        text = ''
          exec nix-update --override-filename by-name/fo/forkgram-desktop/package.nix forkgram-desktop.unwrapped "$@"
        '';
      };
    };
  })
