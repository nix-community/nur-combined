{
  buildMozillaMach,
  buildNpmPackage,
  fetchFromGitHub,
  writeScriptBin,
  runtimeShell,
  rustPlatform,
  vips,
  lib,
  fetchurl,
  callPackage,
  gitMinimal,
  python3Minimal,
  pkg-config,
  nixosTests,
  cargo,
  runCommand,
}:

let
  version = "1.21.10b";
  firefoxVersion = "153.0.1";

  firefoxSrc = fetchurl {
    url = "https://archive.mozilla.org/pub/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.xz";
    hash = "sha512-MQ0aont5Au9eBSli47fSgZ0PX25Zb93q/uU/Cek5DUgB9bZU9Moen9TBXHEkH8MYRK+qTQhvgsUbUWpAH75/QA==";
  };

  patchedSurfer = buildNpmPackage {
    pname = "surfer-patched";
    version = "0-unstable-2026-01-25";

    src = fetchFromGitHub {
      owner = "zen-browser";
      repo = "surfer";
      rev = "17d9a1577170880cdac13dca7c3d6871716fc046";
      hash = "sha256-NzpGimeX8+qv8dfcYWdhYYhWg+2CD5PVdrTWa+cGbR4=";
    };

    nativeBuildInputs = [ pkg-config ];
    # TODO: this should be in nativeBuildInputs, since sharp is only used during build, but it doesn't seem to be
    # visible in there. why not?
    buildInputs = [ vips ];

    patches = [
      ./patch-surfer-git-usage.patch
    ];

    npmDepsHash = "";
    makeCacheWritable = true;
  };

  patchedSrc = buildNpmPackage (finalAttrs: {
    pname = "firefox-zen-browser-src-patched";
    inherit version;
    inherit (patchedSurfer) buildInputs; # Requires surfer deps still because surfer is still in package.json

    src = fetchFromGitHub {
      owner = "zen-browser";
      repo = "desktop";
      tag = version;
      hash = "sha256-76mvf87FU6R1FDFRlDBYOEH6J1ha8IpcA/3KtBkjkRY=";
      fetchSubmodules = true;
    };

    postUnpack = ''
      mkdir source/engine
      tar --extract --file=${firefoxSrc} --directory=source/engine --strip-components=1
    '';

    npmDepsHash = "sha256-rfVWUQxCBZGIM7QHYxQlTYd6yWH5fIY74yhGU0ZY4rQ=";

    makeCacheWritable = true;

    # NOTE: this is used for the ffprefs step.
    cargoDeps = rustPlatform.fetchCargoVendor {
      pname = "zen-browser-ffprefs";
      inherit (finalAttrs) version src cargoRoot;
      hash = "sha256-DZMwxeulQiIiSATU0MoyqiUMA0USZq6umhkr67hZH1Q=";
    };
    cargoRoot = "tools/ffprefs";

    # Requires surfer deps still because surfer is still in package.json
    nativeBuildInputs = patchedSurfer.nativeBuildInputs ++ [
      cargo
      gitMinimal
      python3Minimal
      rustPlatform.cargoCheckHook
      rustPlatform.cargoSetupHook
      (writeScriptBin "iconutil" ''
        #!${runtimeShell}
        echo >&2 "$@"
      '')
      (writeScriptBin "sips" ''
        #!${runtimeShell}
        echo >&2 "$@"
      '')
    ];

    buildPhase = ''
      runHook preBuild

      npm run surfer ci --brand release --display-version ${version}
      npm run import
      python scripts/update_en_US_packs.py

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r engine $out

      cd $out
      for i in $(find . -type l); do
        realpath=$(readlink $i)
        rm $i
        cp $realpath $i
      done

      runHook postInstall
    '';

    dontFixup = true;
  });
in
((buildMozillaMach {
  pname = "zen-browser";
  packageVersion = version;
  version = firefoxVersion;
  applicationName = "zen";
  branding = "browser/branding/release";
  requireSigning = false;
  allowAddonSideload = true;

  src = patchedSrc;

  extraConfigureFlags = [
    "--with-app-basename=Zen"
  ];

  tests = { inherit (nixosTests) zen-browser; };
  updateScript = callPackage ./update.nix { };

  meta = {
    description = "Firefox based browser with a focus on privacy and customization";
    homepage = "https://zen-browser.app";
    downloadPage = "https://zen-browser.app/download";
    changelog = "https://zen-browser.app/release-notes/#${version}";
    maintainers = with lib.maintainers; [
      matthewpi
      titaniumtown
      eveeifyeve
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
    updateScript = callPackage ./update.nix {
      attrPath = "zen-browser-unwrapped";
    };
    license = lib.licenses.mpl20;
    mainProgram = "firefox";
  };

}).overrideAttrs (old: {
  configureFlags = lib.map (f:
    if lib.hasPrefix "--with-wasi-sysroot=" f then
      let
        originalWasiSysRoot = lib.removePrefix "--with-wasi-sysroot=" f;
        newWasiSysRoot = runCommand "wasi-sysroot-fixed" {} ''
          cp -rs ${originalWasiSysRoot} $out
          chmod -R +w $out/lib
          cd $out/lib
          if [ -d "wasm32-wasi" ]; then
            ln -s wasm32-wasi wasm32-wasip1
            ln -s wasm32-wasi wasm32-unknown-wasi
            ln -s wasm32-wasi wasm32-unknown-wasip1
          elif [ -d "wasm32-wasip1" ]; then
            ln -s wasm32-wasip1 wasm32-wasi
            ln -s wasm32-wasip1 wasm32-unknown-wasi
            ln -s wasm32-wasip1 wasm32-unknown-wasip1
          fi
        '';
      in "--with-wasi-sysroot=${newWasiSysRoot}"
    else f
  ) old.configureFlags;
})).override {
  crashreporterSupport = false;
  enableOfficialBranding = false;
}
