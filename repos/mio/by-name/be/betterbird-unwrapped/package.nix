{
  lib,
  buildMozillaMach,
  fetchFromGitHub,
  git,
  libdbusmenu-gtk3 ? null,
  thunderbird-153-unwrapped,
  stdenv,
  fetchhg,
  writers,
  nix-prefetch-hg,
  nix,
}:

let
  betterbirdVersion = "153.5.0esr-bb11";
  majVer = lib.versions.major betterbirdVersion;

  thunderbird-unwrapped = thunderbird-153-unwrapped;

  betterbird-patches = fetchFromGitHub {
    owner = "Betterbird";
    repo = "thunderbird-patches";
    rev = betterbirdVersion;
    hash = "sha256-P0kaclsWsA39EOlgBqApGpl0qq52h8mrtvzG+SnWUDM=";
  };

  # Fetch and extract comm subdirectory
  comm-source = fetchhg {
    name = "comm-source";
    url = "https://hg.mozilla.org/releases/comm-esr${majVer}";
    rev = "9d5971ae648b0d17ab57509dcdcb0a06d3fdbe14";
    hash = "sha256-sTecjw3PnVoYJgxjziRu+8xqlgTutMznCD7RD2bbAl0=";
  };

  updatePackage = writers.writePython3Bin "update-betterbird" {
    libraries = (p: [ p.requests ]);
    flakeIgnore = [ "E501" ];
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        nix
        nix-prefetch-hg
      ])
    ];
  } ./update.py;
in
(
  (buildMozillaMach {
    pname = "betterbird";
    version = betterbirdVersion;

    updateScript = [
      updatePackage
      ./.
    ];

    # Keep binaryName as "thunderbird" so --with-app-name=thunderbird is passed
    # The betterbird patches change the BINARY variable to "betterbird" while keeping MOZ_APP_NAME=thunderbird
    applicationName = "Betterbird";
    binaryName = "thunderbird";
    finalBinaryName = "betterbird";
    distributionId = if stdenv.hostPlatform.isDarwin then "eu.betterbird" else "org.nixos";
    application = "comm/mail";
    branding = "comm/mail/branding/betterbird";
    requireSigning = false;
    inherit (thunderbird-unwrapped) extraPatches;

    src = fetchhg {
      name = "mozilla-source";
      url = "https://hg.mozilla.org/releases/mozilla-esr${majVer}";
      rev = "3806652efdaccfd958d04803eddd3fdf131cd0cd";
      hash = "sha256-L/Mw45Bhuy67dL7YWrsZ5HUWdvRUthJN79DjbL329OY=";
    };

    unpackPhase = ''
      runHook preUnpack

      mozillaDir="$PWD/mozillaDir"
      # --no-preserve=mode doesn't work because it also removes executable bit
      cp -r -T "$src" "$mozillaDir"
      chmod +w "$mozillaDir"
      cp -r -T ${comm-source} "$mozillaDir/comm"
      chmod +w -R "$mozillaDir"

      # Change into the source directory
      cd "$mozillaDir"

      # Set sourceRoot for the build
      sourceRoot="$mozillaDir"

      runHook postUnpack
    '';

    extraPostPatch = thunderbird-unwrapped.extraPostPatch or "" + /* bash */ ''
      echo "extraPostPatch START"
      declare bb_patches="$(mktemp -d --suffix=_bb_patches)"
      cp -r -T --no-preserve=mode "${betterbird-patches}/${majVer}" "$bb_patches"

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
        declare patchLine=""
        for patchLine in "''${patchLines[@]}"; do
          patchLine="''${patchLine%%#*}"
          trim_var patchLine
          if [[ -z $patchLine ]]; then
            continue
          fi

          (
            cd -- "$srcRoot"
            echo "Applying patch $patchLine in $PWD"
            ${lib.getExe git} apply -p1 -v --allow-empty < "$bb_patches/$patchLine"
          )
        done
      }

      applyPatches series-moz .
      applyPatches series comm
      echo "extraPostPatch END"
    '';

    extraBuildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin && libdbusmenu-gtk3 != null) [
      libdbusmenu-gtk3
    ];

    # Environment variables from official build
    extraPreConfigure = ''
      export MOZ_APP_REMOTINGNAME=eu.betterbird.Betterbird
      export MOZ_REQUIRE_ADDON_SIGNING=0
    '';

    withWasiSysroot = false;

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

    extraPassthru = {
      inherit betterbird-patches comm-source updatePackage;
    };

    meta = {
      description = "a fine-tuned version of Mozilla Thunderbird, Thunderbird on steroids, if you will";
      homepage = "https://www.betterbird.eu/";
      maintainers = with lib.maintainers; [
        shelvacu
        mio
      ];
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
    }
)
