{
  buildMozillaMach,
  buildNpmPackage,
  fetchFromGitHub,
  writeShellScriptBin,
  rustPlatform,
  vips,
  lib,
  stdenv,
  fetchurl,
  callPackage,
  gitMinimal,
  python3Minimal,
  pkg-config,
  cargo,
  imagemagick,
  libicns,
}:

let
  version = "1.21.10b";
  firefoxVersion = "153.0.1";

  firefoxSrc = fetchurl {
    url = "mirror://mozilla/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.xz";
    hash = "sha512-MQ0aont5Au9eBSli47fSgZ0PX25Zb93q/uU/Cek5DUgB9bZU9Moen9TBXHEkH8MYRK+qTQhvgsUbUWpAH75/QA==";
  };

  # Surfer's async-icns shells out to macOS iconutil/sips. Provide nixpkgs-style
  # replacements (cf. bsnes-hd/higan using png2icns) only on Darwin; Linux skips
  # Mac icon generation and does not need stubs.
  macIconTools = lib.optionals stdenv.hostPlatform.isDarwin [
    (writeShellScriptBin "iconutil" ''
      set -euo pipefail
      if [ "''${1-}" = "--convert" ] && [ "''${2-}" = "icns" ] && [ "''${3-}" = "--output" ]; then
        out="$4"
        iconset="$5"
        shopt -s nullglob
        inputs=()
        for f in "$iconset"/*.png; do
          case "$f" in
            *@2x.png) continue ;;
          esac
          inputs+=("$f")
        done
        exec ${lib.getExe' libicns "png2icns"} "$out" "''${inputs[@]}"
      fi
      echo >&2 "$@"
    '')
    (writeShellScriptBin "sips" ''
      set -euo pipefail
      # async-icns: sips SOURCE -Z SIZE --out DEST
      if [ "''${2-}" = "-Z" ] && [ "''${4-}" = "--out" ]; then
        exec ${lib.getExe imagemagick} "$1" -resize "$3x$3" "$5"
      fi
      echo >&2 "$@"
    '')
  ];

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
    # TODO: this should be in nativeBuildInputs, since sharp is only used during
    # build, but it doesn't seem to be visible in there. why not?
    buildInputs = [ vips ];

    patches = [ ./patch-surfer-git-usage.patch ];

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
    nativeBuildInputs =
      patchedSurfer.nativeBuildInputs
      ++ [
        cargo
        gitMinimal
        python3Minimal
        rustPlatform.cargoCheckHook
        rustPlatform.cargoSetupHook
      ]
      ++ macIconTools;

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
(buildMozillaMach {
  pname = "zen-browser";
  packageVersion = version;
  version = firefoxVersion;
  applicationName = "Zen";
  binaryName = "zen";
  branding = "browser/branding/release";
  requireSigning = false;
  allowAddonSideload = true;

  src = patchedSrc;

  extraConfigureFlags = [
    "--with-app-basename=Zen"
  ];

  updateScript = callPackage ./update.nix {
    attrPath = "zen-browser";
  };

  meta = {
    # since Firefox 60, build on 32-bit platforms fails with "out of memory".
    # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    broken = stdenv.buildPlatform.is32bit;
    description = "Firefox based browser with a focus on privacy and customization";
    homepage = "https://zen-browser.app";
    changelog = "https://zen-browser.app/release-notes/#${version}";
    license = lib.licenses.mpl20;
    mainProgram = "zen";
    maintainers = with lib.maintainers; [
      matthewpi
      titaniumtown
      eveeifyeve
    ];
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
    platforms = lib.platforms.unix;
  };
}).override
  {
    crashreporterSupport = false;
    enableOfficialBranding = false;
  }
