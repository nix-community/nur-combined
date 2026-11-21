{
  lib,
  stdenv,
  nixpkgs_pkgs,
  telegram-desktop,
  fetchFromGitHub,
  zbar,
  pango,
  tlottie,
  wallet-engine,
  swift,
  nix-update-script,
}:

let
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

      # nixpkgs' telegram-desktop already pulls its own tlottie and
      # wallet-engine. Forkgram needs the versions packaged here (the C API and
      # the decode-sign-data-cell patch), so replace them rather than keeping
      # both versions in the link path. pango is only in nixpkgs' Linux inputs.
      buildInputs =
        lib.filter (
          p: p != nixpkgs_pkgs.tlottie && p != nixpkgs_pkgs.wallet-engine
        ) previousAttrs.buildInputs
        ++ [
          zbar
          tlottie
          wallet-engine
        ]
        ++ lib.optionals (!stdenv.hostPlatform.isLinux) [ pango ];

      # nixpkgs' swift 6.4.0 chain does not build on aarch64-darwin at this
      # pin: swift-collections 1.7.6 fails in its own postInstall because its
      # dylibs were linked without header padding. Build the macOS app without
      # the Swift 6 on-device translation provider instead of pulling in a
      # toolchain that cannot be built; it is the only Swift code tdesktop
      # compiles on macOS (Telegram/lib_translate).
      cmakeFlags =
        previousAttrs.cmakeFlags
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          (lib.cmakeBool "DESKTOP_APP_DISABLE_SWIFT6" true)
        ];
      nativeBuildInputs =
        if stdenv.hostPlatform.isDarwin then
          lib.remove swift previousAttrs.nativeBuildInputs
        else
          previousAttrs.nativeBuildInputs;

      postPatch = (previousAttrs.postPatch or "") + ''
        (
          cd cmake
          patch -p1 < ../patches/cmake_zbar.patch
        )

        # nixpkgs' cmark-gfm does not expose this newer parser hook.
        substituteInPlace Telegram/SourceFiles/iv/markdown/iv_markdown_parse_convert.cpp \
          --replace-fail 'cmark_parser_set_allocation_abort_flag' '//cmark_parser_set_allocation_abort_flag'
      '';

      passthru = (previousAttrs.passthru or { }) // {
        updateScript = nix-update-script {
          attrPath = "forkgram-desktop.unwrapped";
          extraArgs = [
            "--override-filename"
            "by-name/fo/forkgram-desktop/package.nix"
          ];
        };
      };

      meta = previousAttrs.meta // {
        description = "Forkgram Desktop messaging app";
        homepage = "https://github.com/forkgram/tdesktop";
        changelog = "https://github.com/forkgram/tdesktop/releases/tag/v${finalAttrs.version}";
        mainProgram = "Forkgram";
      };
    }
  );
in
telegram-desktop.override {
  pname = "forkgram-desktop";
  inherit unwrapped;
}
