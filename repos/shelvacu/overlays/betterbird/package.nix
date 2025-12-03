{
  lib,
  thunderbird-128-unwrapped,
  fetchFromGitHub,
  fetchhg,
  runCommandNoCC,
  curl,
  git,
  libdbusmenu,

  # options passed to the thunderbird builder, but with betterbird defaults
  privacySupport ? true,
  requireSigning ? false,
  allowAddonSideload ? true,
}:
let
  majorVersion = "128";
  version = "${majorVersion}.8.0esr-bb23";
  #from Betterbird/thunderbird-patches/blob/main/128/128.sh
  stuff = {
    MOZILLA_REPO = "https://hg.mozilla.org/releases/mozilla-esr128/";
    MOZILLA_REV = "c685d5844a0e4f99ac535b6ffc641fbd07696c68";
    COMM_REPO = "https://hg.mozilla.org/releases/comm-esr128/";
    COMM_REV = "f8183c5232ec457f3c8b5be36c7891d933bbb457";
    RUST_VER = "1.79.0";
    MOZ = "-moz";
    MOZU = "-moz";
  };
  betterbirdPatches = fetchFromGitHub {
    name = "betterbird--thunderbird-patches";
    owner = "Betterbird";
    repo = "thunderbird-patches";
    tag = version;
    hash = "sha256-9UG1juN/vKHY3LRuryjMDdaFapd6y7ySu0Fn3GTeN2w=";
  };
  patchesFromThunderbird =
    runCommandNoCC "betterbird-patches-from-network"
      {
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-4OD7OckIA/qB0jI9dNk1Q6cTZZrKVufDNvPKSeEWYBY=";
      }
      ''
        set -xev
        mkdir -p "$out"
        fetchFromSeries() {
          local seriesFile="$1"
          shift
          filteredSeries="$(mktemp)"
          cat "$seriesFile" | grep " # " | grep -v "^#" | sed 's/ # / /' | sed 's:/rev/:/raw-rev/:' > "$filteredSeries"
          while IFS=" " read -r filename url; do
            ${lib.getExe curl} -v -k "$url" --output "$out/$filename"
          done < "$filteredSeries"
        }
        fetchFromSeries ${betterbirdPatches}/${majorVersion}/series${stuff.MOZU}
        fetchFromSeries ${betterbirdPatches}/${majorVersion}/series
      '';
  mozilla_src = fetchhg {
    name = "mozilla--mozilla";
    url = stuff.MOZILLA_REPO;
    rev = stuff.MOZILLA_REV;
    hash = "sha256-5p5CY+luDsjwUCL6/wbzT7/0mQ4IJQKyXj3Ty4j+In4=";
  };
  comm_src = fetchhg {
    name = "mozilla--comm";
    url = stuff.COMM_REPO;
    rev = stuff.COMM_REV;
    hash = "sha256-WVRmlqd7+1Noq+I91cm334LIY5uxRUs/w8K48E57WKY=";
  };
  replacement_src = runCommandNoCC "combined-source-from-hg" { } ''
    set -xev
    cp -r ${mozilla_src} "$out"
    chmod u+w "$out"
    cp -r ${comm_src} "$out/comm"
    chmod -R u+w "$out"
    allBetterbirdPatches="$(mktemp -d)"
    cp ${patchesFromThunderbird}/* "$allBetterbirdPatches"
    cp ${betterbirdPatches}/${majorVersion}/branding/*.patch "$allBetterbirdPatches"
    cp ${betterbirdPatches}/${majorVersion}/bugs/*.patch "$allBetterbirdPatches"
    cp ${betterbirdPatches}/${majorVersion}/features/*.patch "$allBetterbirdPatches"
    cp ${betterbirdPatches}/${majorVersion}/misc/*.patch "$allBetterbirdPatches"
    applySeries() {
      local seriesFile="$1"
      shift
      local onFolder="$1"
      shift
      local patches=()
      local aaa="$(mktemp)"
      cat "$seriesFile" | grep -v "^#" | sed 's/ \?#.*//' > "$aaa"
      while IFS=" " read -r line; do
        patches+=("$line")
      done < "$aaa"
      for patchName in "''${patches[@]}"; do
        ${lib.getExe git} apply --unsafe-paths --verbose --directory="$onFolder" -p1 "$allBetterbirdPatches/$patchName"
      done
    }
    applySeries ${betterbirdPatches}/${majorVersion}/series${stuff.MOZU} "$out"
    applySeries ${betterbirdPatches}/${majorVersion}/series "$out/comm"
  '';
in
(thunderbird-128-unwrapped.override { inherit privacySupport requireSigning allowAddonSideload; })
.overrideAttrs
  (old: rec {
    pname = "betterbird";
    inherit version;
    name = "${pname}-${version}";

    buildInputs = (old.buildInputs or [ ]) ++ [ libdbusmenu ];

    src = replacement_src;

    configureFlags = (old.configureFlags or [ ]) ++ [
      # "--enable-application=comm/mail"
      "--with-branding=comm/mail/branding/betterbird"
      # "--disable-updater"
      # "--disable-crashreporter"
      # "--enable-tests"
      # "--without-wasm-sandboxed-libraries"
      # "--with-unsigned-addon-scopes=app,system"
      # "--allow-addon-sideload"
      # "--enable-default-toolkit=cairo-gtk3-wayland"
      # "--enable-official-branding"
    ];

    preConfigure = (old.preConfigure or "") + ''
      # Disable enforcing that add-ons are signed.
      export MOZ_REQUIRE_SIGNING=
      export MOZ_REQUIRE_ADDON_SIGNING=0

      # For NSS symbols
      export MOZ_DEBUG_SYMBOLS=1

      # Set the WM_CLASS referenced in the .desktop file.
      export MOZ_APP_REMOTINGNAME=eu.betterbird.Betterbird

      # Needed to enable breakpad in application.ini
      # The preceding comment appears all over the Mozilla repos, however it is misleading.
      # "Official" (server) builds, as opposed to local builds, should have nothing to do
      # with "breakpad" (https://chromium.googlesource.com/breakpad/) crash reporting.
      # In any case, we don't want a local build.
      export MOZILLA_OFFICIAL=1

      export MOZ_TELEMETRY_REPORTING=  # No telemetry.

      # Used for Linux to create small launcher executable for file browsers.
      # See https://hg.mozilla.org/mozilla-central/rev/3cbbfc5127e4 for details.
      export MOZ_NO_PIE_COMPAT=1
    '';

    passthru = (old.passthru or { }) // {
      inherit
        betterbirdPatches
        mozilla_src
        comm_src
        replacement_src
        patchesFromThunderbird
        ;
    };
  })
