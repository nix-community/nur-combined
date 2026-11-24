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
  rustPlatform,
  cargo,
  rustc,
  writeShellScript,
  nix-update-script,
}:

let
  # 7.4.6 builds the widget helper (Telegram/ThirdParty/twidget) with cargo. The
  # lock file is vendored from that submodule: cargo runs from the build tree with
  # a CARGO_HOME the cmake script controls, so wrap it to use the vendored crates
  # and stay offline.
  widgetHelperCargoDeps = rustPlatform.fetchCargoVendor {
    name = "forkgram-widget-helper-cargo-vendor";
    src = ./widget-cargo;
    hash = "sha256-NAjFvRuwebJ3sWVNhnEfyzBa3i8MTFG3lHJ7f3Keqb4=";
  };

  widgetHelperCargo = writeShellScript "forkgram-widget-helper-cargo" ''
    cargo_home="''${TMPDIR:-/tmp}/forkgram-widget-helper-cargo"
    mkdir -p "$cargo_home"
    sed "s|@vendor@|${widgetHelperCargoDeps}|g" \
      "${widgetHelperCargoDeps}/.cargo/config.toml" > "$cargo_home/config.toml"
    export CARGO_HOME="$cargo_home"
    export CARGO_NET_OFFLINE=true
    export PATH="${cargo}/bin:${rustc}/bin:$PATH"
    exec ${cargo}/bin/cargo "$@"
  '';
  unwrapped = telegram-desktop.unwrapped.overrideAttrs (
    finalAttrs: previousAttrs: {
      pname = "forkgram-desktop-unwrapped";
      version = "7.4.6";

      src = fetchFromGitHub {
        owner = "forkgram";
        repo = "tdesktop";
        tag = "v${finalAttrs.version}";
        fetchSubmodules = true;
        hash = "sha256-K55ARXQOhJ9gCGQedGDIXWoA0KwaTo6doR+/g8kKFhc=";
      };

      # nixpkgs' telegram-desktop already pulls its own tlottie and
      # wallet-engine. Forkgram needs the versions packaged here (the C API and
      # the signData cell decoding), so replace them rather than keeping both
      # versions in the link path. pango is only in nixpkgs' Linux inputs.
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
        ++ [ (lib.cmakeFeature "TDESKTOP_CARGO" "${widgetHelperCargo}") ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          (lib.cmakeBool "DESKTOP_APP_DISABLE_SWIFT6" true)
        ];
      nativeBuildInputs =
        (
          if stdenv.hostPlatform.isDarwin then
            lib.remove swift previousAttrs.nativeBuildInputs
          else
            previousAttrs.nativeBuildInputs
        )
        ++ [
          cargo
          rustc
        ];

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
