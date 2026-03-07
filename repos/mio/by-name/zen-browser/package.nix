{
  buildMozillaMach,
  buildNpmPackage,
  fetchFromGitHub,
  writeScriptBin,
  runtimeShell,
  vips,
  lib,
  fetchurl,
  stdenvNoCC,
  git,
  python3,
  pkg-config,
}:

let
  version = "1.19.1b";
  firefoxVersion = "148.0";

  firefoxSrc = fetchurl {
    url = "https://archive.mozilla.org/pub/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.xz";
    hash = "sha256-7JPlBAojt9vp7HfrSnzNqYIIVteFG/L2F/NnO2NUy28";
  };

  patchedSrc = buildNpmPackage {
    pname = "firefox-zen-browser-src-patched";
    inherit version;

    src = fetchFromGitHub {
      owner = "zen-browser";
      repo = "desktop";
      tag = version;
      hash = "sha256-a0Uxwjd8//IKZQhIxnF/pYBtq/FX9CBs5wU4k9tAS2g=";
      fetchSubmodules = true;
    };

    postUnpack = ''
      tar xf ${firefoxSrc}
      mkdir -p source/engine
      mv firefox-${firefoxVersion} source/engine
    '';

    npmDepsHash = "sha256-OXaKdgH5VV4YrsiaR3MmT7EyZhfKMeK3MyQ/Ha3V6lg=";

    makeCacheWritable = true;

    nativeBuildInputs = [
      git
      python3
      pkg-config
      (writeScriptBin "sips" ''
        #!${runtimeShell}
        echo >&2 "$@"
      '')
      (writeScriptBin "iconutil" ''
        #!${runtimeShell}
        echo >&2 "$@"
      '')
    ];
    # TODO: this should be in nativeBuildInputs, since sharp is only used during build, but it doesn't seem to be
    # visible in there. why not?
    buildInputs = [
      vips
    ];

    buildPhase = ''
      npm run surfer ci --brand release --display-version ${version}
      npm run import
      python ./scripts/update_en_US_packs.py
    '';

    installPhase = ''
      cp -r engine $out

      cd $out
      for i in $(find . -type l); do
        realpath=$(readlink $i)
        rm $i
        cp $realpath $i
      done
    '';

    dontFixup = true;
  };
in
(buildMozillaMach {
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

  meta = {
    description = "Firefox based browser with a focus on privacy and customization";
    homepage = "https://zen-browser.app/";
    downloadPage = "https://zen-browser.app/download/";
    changelog = "https://zen-browser.app/release-notes/#${version}";
    maintainers = with lib.maintainers; [
      matthewpi
      titaniumtown
      eveeifyeve
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    broken = false; # Broken for now because major issue with getting rid of surfer.
    # since Firefox 60, build on 32-bit platforms fails with "out of memory".
    # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
    license = lib.licenses.mpl20;
  };
}).override
  {
    pgoSupport = false;
    crashreporterSupport = false;
    enableOfficialBranding = false;
  }
