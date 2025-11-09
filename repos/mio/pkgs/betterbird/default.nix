{
  lib,
  buildMozillaMach,
  cacert,
  curl,
  fetchFromGitHub,
  fetchurl,
  git,
  libdbusmenu-gtk3 ? null,
  runtimeShell,
  thunderbirdPackages,
  unzip,
  stdenv,
}:

let
  thunderbird-unwrapped = thunderbirdPackages.thunderbird-140;

  version = "140.5.0esr";
  majVer = lib.versions.major version;

  betterbird-patches = fetchFromGitHub {
    owner = "Betterbird";
    repo = "thunderbird-patches";
    rev = "${version}-bb14";
    postFetch = ''
      export PATH=${lib.makeBinPath [ curl ]}:$PATH
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

      echo "Retrieving external patches"
      cd $out/${majVer}

      # Create directories for external patches
      mkdir -p external

      # Download external patches for Mozilla repo (series-M-C)
      if [ -f series-M-C ]; then
        echo "Processing series-M-C for Mozilla external patches"
        grep " # " series-M-C | grep -v "^#" | while read line || [[ -n $line ]]; do
          patch=$(echo "$line" | cut -f1 -d'#' | sed 's/ *$//')
          url=$(echo "$line" | cut -f2 -d'#' | sed 's/^ *//')
          if [[ -n "''${patch// }" ]] && [[ -n "''${url// }" ]]; then
            url=$(echo "$url" | sed 's/\/rev\//\/raw-rev\//')
            echo "Downloading $patch from $url"
            curl -L -f "$url" -o external/$patch
          fi
        done
      fi

      # Download external patches for comm repo (series)
      if [ -f series ]; then
        echo "Processing series for comm external patches"
        grep " # " series | grep -v "^#" | while read line || [[ -n $line ]]; do
          patch=$(echo "$line" | cut -f1 -d'#' | sed 's/ *$//')
          url=$(echo "$line" | cut -f2 -d'#' | sed 's/^ *//')
          if [[ -n "''${patch// }" ]] && [[ -n "''${url// }" ]]; then
            url=$(echo "$url" | sed 's/\/rev\//\/raw-rev\//')
            echo "Downloading $patch from $url"
            curl -L -f "$url" -o external/$patch
          fi
        done
      fi
    '';
    hash = "sha256-jAZGcR8ri1jXaRjgVN5q3zxOrVR7OB+tnJNGwjfctWc=";
  };
  # Fetch and extract comm subdirectory
  # https://github.com/Betterbird/thunderbird-patches/blob/main/140/140.sh
  comm-source = fetchurl {
    url = "https://hg-edge.mozilla.org/releases/comm-esr${majVer}/archive/6a3011b7161c6f3a36d5116f2608d51b19fb4d58.zip";
    hash = "sha256-K7BBwMmePC4MoD6xllklbh58I1a65fajO846qRDacEk=";
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

    src = fetchurl {
      # https://download.cdn.mozilla.net/pub/thunderbird/releases/
      #url = "mirror://mozilla/thunderbird/releases/${version}/source/thunderbird-${version}.source.tar.xz";
      # https://github.com/Betterbird/thunderbird-patches/blob/main/140/140.sh
      url = "https://hg-edge.mozilla.org/releases/mozilla-esr${majVer}/archive/558705980ca9db16de0564b5a6031b5d6e0a7efe.zip";
      hash = "sha256-f2qBCXFW7EGrWUORB3+YYEzYYpnlrJ71Gn0EKO2+K00=";
    };

    unpackPhase = ''
      runHook preUnpack

      # Extract mozilla source
      unzip -q $src
      mozillaDir=$(echo mozilla-esr${majVer}-*)

      # Extract comm source
      unzip -q ${comm-source}
      commDir=$(echo comm-esr${majVer}-*)

      # Move comm into mozilla directory
      mv "$commDir" "$mozillaDir/comm"

      # Change into the source directory
      cd "$mozillaDir"
      chmod -R +w .

      # Set sourceRoot for the build
      sourceRoot="$PWD"

      runHook postUnpack
    '';

    extraPostPatch = thunderbird-unwrapped.extraPostPatch or "" + /* bash */ ''
      PATH=$PATH:${lib.makeBinPath [ git ]}
      patches=$(mktemp -d)
      for dir in branding bugs features misc; do
        if [ -d ${betterbird-patches}/${majVer}/$dir ]; then
          cp -r ${betterbird-patches}/${majVer}/$dir/*.patch $patches/
        fi
      done
      # Copy external patches if they exist
      if [ -d ${betterbird-patches}/${majVer}/external ]; then
        cp -r ${betterbird-patches}/${majVer}/external/*.patch $patches/
      fi
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

      while read patch; do
        patch="''${patch%%#*}"
        patch="''${patch% }"
        if [[ $patch == "" ]]; then
          continue
        fi

        # requires vendored icu, fails to link with our icu
        # feature-506064 depends on those icu patches
        if [[ $patch == 14-feature-regexp-searchterm.patch || $patch == 14-feature-regexp-searchterm-m-c.patch || $patch == feature-506064-match-diacritics.patch || $patch == feature-506064-match-diacritics-m-c.patch ]]; then
          continue
        fi

        # failed to apply. thunderbird-patches/140/bugs/*
        if [[ $patch == 1976738-font-colour-plaintext.patch || $patch == 1976738-font-colour-plaintext-take2.patch ]]; then
          continue
        fi

        echo Applying patch $patch.
        if [[ $patch == *-m-c.patch ]]; then
          git apply -p1 -v --allow-empty < $patches/$patch
        else
          cd comm
          git apply -p1 -v --allow-empty < $patches/$patch
          cd ..
        fi
      done < <(cat $patches/series $patches/series-M-C)
    '';

    extraBuildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin && libdbusmenu-gtk3 != null) [
      libdbusmenu-gtk3
    ];

    meta = with lib; {
      description = "Betterbird is a fine-tuned version of Mozilla Thunderbird, Thunderbird on steroids, if you will";
      homepage = "https://www.betterbird.eu/";
      mainProgram = "betterbird";
      maintainers = with maintainers; [ SuperSandro2000 ];
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

    pgoSupport = false; # console.warn: feeds: "downloadFeed: network connection unavailable"

    inherit (thunderbird-unwrapped.passthru) icu73;
  }
).overrideAttrs
  (oldAttrs: {
    postInstall = oldAttrs.postInstall or "" + ''
      mkdir -p $out/lib/betterbird
      mv $out/lib/thunderbird/* $out/lib/betterbird/
      rmdir $out/lib/thunderbird
      rm $out/bin/thunderbird
      ln -srf $out/lib/betterbird/betterbird $out/bin/betterbird
    '';

    doInstallCheck = false;

    passthru = oldAttrs.passthru // {
      inherit betterbird-patches;
    };
  })
