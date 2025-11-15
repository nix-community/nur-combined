{
  lib,
  buildMozillaMach,
  fetchFromGitHub,
  fetchurl,
  git,
  libdbusmenu-gtk3 ? null,
  thunderbirdPackages,
  stdenv,
  linkFarmFromDrvs,
  fetchhg,
  wrapThunderbird,
}:

let
  thunderbird-unwrapped =
    (thunderbirdPackages.thunderbird-140.override {
      crashreporterSupport = false;
    }).overrideAttrs
      rec {
        version = "140.5.0esr";
        src = fetchurl {
          url = "mirror://mozilla/thunderbird/releases/${version}/source/thunderbird-${version}.source.tar.xz";
          hash = "sha256-y40QaTu8BMS/xTnEVgd5+0NrQDJr9w30wII6wSW4FeU=";
        };
      };

  version = "140.5.0esr";
  majVer = lib.versions.major version;

  betterbird-patches = fetchFromGitHub {
    owner = "Betterbird";
    repo = "thunderbird-patches";
    rev = "${version}-bb14";
    hash = "sha256-Hzdm8xpoEqV9BsqW235JrLalq5sUNcvp/QMjU3aSuxI=";
  };

  remote-patch-data = lib.importJSON ./patchdata.json;

  remote-patches = map (
    {
      name,
      url,
      hash,
    }:
    fetchurl {
      inherit name url hash;
    }
  ) remote-patch-data;

  remote-patches-folder = linkFarmFromDrvs "betterbird-remote-patches" remote-patches;

  # Fetch and extract comm subdirectory
  comm-source = fetchhg {
    name = "comm-source";
    url = "https://hg.mozilla.org/releases/comm-esr140";
    rev = "6a3011b7161c6f3a36d5116f2608d51b19fb4d58";
    hash = "sha256-w8KLdxw3r/E3dFM9ejRajMPTsAQ3VRFzF0HBve33JFk=";
  };
in
(
  (buildMozillaMach {
    pname = "betterbird";
    inherit version;

    # Keep binaryName as "thunderbird" so --with-app-name=thunderbird is passed
    # The betterbird patches change the BINARY variable to "betterbird" while keeping MOZ_APP_NAME=thunderbird
    applicationName = "Betterbird";
    binaryName = "thunderbird";
    application = "comm/mail";
    branding = "comm/mail/branding/betterbird";
    inherit (thunderbird-unwrapped) extraPatches;

    src = fetchhg {
      name = "mozilla-source";
      url = "https://hg.mozilla.org/releases/mozilla-esr140";
      rev = "558705980ca9db16de0564b5a6031b5d6e0a7efe";
      hash = "sha256-IS/rn7qvnmEqMh8IRsCFNH5Y0C/7KXGDAuPPcjCqcFc=";
    };

    unpackPhase = ''
      runHook preUnpack

      mozillaDir="$PWD/mozillaDir"
      cp -r "$src" "$mozillaDir"
      chmod +w "$mozillaDir"

      cp -r ${comm-source} "$mozillaDir/comm"

      # Change into the source directory
      cd "$mozillaDir"
      chmod -R +w .

      # Set sourceRoot for the build
      sourceRoot="$mozillaDir"

      runHook postUnpack
    '';

    extraPostPatch = thunderbird-unwrapped.extraPostPatch or "" + /* bash */ ''
      patches=$(mktemp -d)
      for dir in branding bugs features misc; do
        if [ -d ${betterbird-patches}/${majVer}/$dir ]; then
          cp ${betterbird-patches}/${majVer}/$dir/*.patch $patches/
        fi
      done
      # Copy external patches
      cp ${remote-patches-folder}/*.patch $patches/

      cp ${betterbird-patches}/${majVer}/series* $patches/
      chmod -R +w $patches

      cd $patches
      # fix FHS paths to libdbusmenu (only on non-Darwin when libdbusmenu-gtk3 is available)
      ${lib.optionalString (!stdenv.hostPlatform.isDarwin && libdbusmenu-gtk3 != null) ''
        substituteInPlace 12-feature-linux-systray.patch \
          --replace-fail "/usr/include/libdbusmenu-glib-0.4/" "${lib.getDev libdbusmenu-gtk3}/include/libdbusmenu-glib-0.4/" \
          --replace-fail "/usr/include/libdbusmenu-gtk3-0.4/" "${lib.getDev libdbusmenu-gtk3}/include/libdbusmenu-gtk3-0.4/"
      ''}
      cd -

      chmod -R +w dom/base/test/gtest/

      function trim_var() {
          declare -n var_ref="$1"
          # remove leading whitespace characters
          var_ref="''${var_ref#"''${var_ref%%[![:space:]]*}"}"
          # remove trailing whitespace characters
          var_ref="''${var_ref%"''${var_ref##*[![:space:]]}"}"
      }

      function applyPatches() {
        declare seriesFileName="$1" srcRoot="$2"
        declare seriesFilePath="${betterbird-patches}/${majVer}/$seriesFileName"
        declare -a patchLines=()
        mapfile -t patchLines <"$seriesFilePath"
        declare patch=""
        for patch in "''${patchLines[@]}"; do
          patch="''${patch%%#*}"
          trim_var patch
          if [[ $patch == "" ]]; then
            continue
          fi

          # requires vendored icu, fails to link with our icu
          # feature-506064 depends on those icu patches
          if [[ $patch == 14-feature-regexp-searchterm.patch || $patch == 14-feature-regexp-searchterm-moz.patch || $patch == feature-506064-match-diacritics.patch || $patch == feature-506064-match-diacritics-moz.patch ]]; then
            continue
          fi
          (
            cd -- "$srcRoot"
            echo "Applying patch $patch in $PWD"
            ${lib.getExe git} apply -p1 -v --allow-empty < $patches/$patch
          )
        done
      }

      applyPatches series-moz .
      applyPatches series comm
    '';

    extraBuildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin && libdbusmenu-gtk3 != null) [
      libdbusmenu-gtk3
    ];

    # Additional mozconfig options from official Betterbird build
    extraConfigureFlags = [
      "--with-unsigned-addon-scopes=app,system"
      "--allow-addon-sideload"
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      "--enable-default-toolkit=cairo-gtk3-wayland"
    ]
    ++ [
      "--without-wasm-sandboxed-libraries"
    ];

    meta = {
      description = "Betterbird is a fine-tuned version of Mozilla Thunderbird, Thunderbird on steroids, if you will";
      homepage = "https://www.betterbird.eu/";
      mainProgram = "betterbird";
      inherit (thunderbird-unwrapped.meta)
        platforms
        broken
        license
        ;
    };
  }).override
  {
    crashreporterSupport = false; # not supported
    geolocationSupport = false;
    webrtcSupport = false;

    pgoSupport = false; # console.warn: feeds: "downloadFee d: network connection unavailable"

    inherit (thunderbird-unwrapped.passthru) icu73 icu77;
  }
).overrideAttrs
  (oldAttrs: {
    # Remove wasi-sysroot flag - not available in Betterbird/Thunderbird 140 configuration
    configureFlags = lib.filter (
      flag: !lib.hasPrefix "--with-wasi-sysroot=" flag
    ) oldAttrs.configureFlags;

    setSourceRoot = ''
      sourceRoot="$mozillaDir"
    '';

    # Environment variables from official build
    preConfigure = (oldAttrs.preConfigure or "") + ''
      export MOZ_APP_REMOTINGNAME=eu.betterbird.Betterbird
      export MOZ_REQUIRE_SIGNING=
      export MOZ_REQUIRE_ADDON_SIGNING=0
    '';

    # On Darwin, use stage-package target and handle the .app installation
    installTargets = lib.optionalString stdenv.hostPlatform.isDarwin "stage-package";

    postInstall =
      lib.optionalString stdenv.hostPlatform.isDarwin ''
        # Copy the .app bundle from dist/ to Applications/
        # Use -L to dereference symlinks (copy actual files instead of symlinks)
        mkdir -p $out/Applications
        cp -rL dist/Betterbird.app "$out/Applications/"

        # Create symlink in bin
        mkdir -p $out/bin
        ln -sf $out/Applications/Betterbird.app/Contents/MacOS/betterbird $out/bin/betterbird
      ''
      + lib.optionalString (!stdenv.hostPlatform.isDarwin) (
        (oldAttrs.postInstall or "")
        + ''
          mkdir -p $out/lib/betterbird
          mv $out/lib/thunderbird/* $out/lib/betterbird/
          rmdir $out/lib/thunderbird
          rm $out/bin/thunderbird
          ln -srf $out/lib/betterbird/betterbird $out/bin/betterbird
        ''
      );

    doInstallCheck = false;

    passthru = oldAttrs.passthru // {
      inherit
        betterbird-patches
        remote-patches-folder
        comm-source
        thunderbird-unwrapped
        ;
      thunderbird = wrapThunderbird thunderbird-unwrapped { };
    };
  })
