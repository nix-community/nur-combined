{
  lib,
  fetchurl,
  runCommand,
  writeText,
  buildMozillaMach,
  wrapFirefox,
  tor,
  lyrebird,
}:

let
  # Tor Browser version and the Firefox ESR version it is based on. The
  # mapping is taken from the source tarball published at
  # https://dist.torproject.org/torbrowser/<version>/
  version = "15.0.19";
  # buildMozillaMach selects patches and toolchains based on the Firefox
  # version, so it is tracked separately from the Tor Browser version.
  firefoxVersion = "140.13.0";
  srcVersion = "140.13.0esr-15.0-1-build2";

  src = fetchurl {
    urls = [
      "https://dist.torproject.org/torbrowser/${version}/src-firefox-tor-browser-${srcVersion}.tar.xz"
      "https://archive.torproject.org/tor-package-archive/torbrowser/${version}/src-firefox-tor-browser-${srcVersion}.tar.xz"
    ];
    hash = "sha256-3R8PZmnes9Irs/fhFl4yCTgmwrr8DVxiLgIRT1O7UqU=";
  };

  # The browser's integrated tor-launcher (toolkit/components/tor-launcher)
  # spawns a tor daemon itself and derives the GeoIP file paths from the
  # torrc-defaults location, so keep all of them together here. The
  # torrc-defaults mirrors the one shipped with the official Tor Browser
  # builds, with the daemon and pluggable transports taken from nixpkgs.
  torData = runCommand "tor-browser-tor-data" { } ''
    mkdir $out
    ln -s ${tor.geoip}/share/tor/geoip ${tor.geoip}/share/tor/geoip6 $out/
    cp ${writeText "torrc-defaults" ''
      # torrc-defaults for tor-browser-from-src.
      #
      # Modelled on the torrc-defaults shipped with the official Tor Browser
      # builds, but using the tor daemon and pluggable transports from
      # nixpkgs. See the extensions.torlauncher.* preferences set by the
      # wrapper; other connection settings are passed on the command line.
      #
      # If non-zero, try to write to disk less frequently than we would otherwise.
      AvoidDiskWrites 1
      # Where to send logging messages.  Format is minSeverity[-maxSeverity]
      # (stderr|stdout|syslog|file FILENAME).
      Log notice stdout
      CookieAuthentication 1
      DormantCanceledByStartup 1
      ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit,webtunnel exec ${lyrebird}/bin/lyrebird
      ClientTransportPlugin snowflake exec ${lyrebird}/bin/lyrebird
    ''} $out/torrc-defaults
  '';

  # Official Tor Browser bundles a set of fonts (Arimo, Cousine, Tinos, the
  # Noto families, CJK and emoji fonts) which its fonts.conf makes the only
  # fonts visible to the browser, so that all users present the same font
  # fingerprint. The firefox source tree only ships fonts.conf and
  # TwemojiMozilla.ttf (browser/fonts/moz.build); the remaining fonts are
  # added by tor-browser-build's "fonts" project when the release tarballs
  # are assembled. Extract the font bundle from the official tarball of the
  # same version so this build ships the exact upstream font set.
  bundledFonts = runCommand "tor-browser-${version}-fonts" {
    src = fetchurl {
      urls = [
        "https://archive.torproject.org/tor-package-archive/torbrowser/${version}/tor-browser-linux-x86_64-${version}.tar.xz"
        "https://dist.torproject.org/torbrowser/${version}/tor-browser-linux-x86_64-${version}.tar.xz"
      ];
      # Same tarball as the `src` of the binary tor-browser package in nixpkgs.
      hash = "sha256-LrSrQx9JIcpjsSO2+fRFoHP797ZfGI9FpXfVdusr4s8=";
    };
  } ''
    mkdir -p $out/fonts
    tar -xJf $src -C $out/fonts --strip-components=3 tor-browser/Browser/fonts
    # fonts.conf locates the font directory relative to the process working
    # directory, which only works when launched from the directory containing
    # fonts/. Point it at the store path instead (same substitution as the
    # binary tor-browser package in nixpkgs).
    substituteInPlace $out/fonts/fonts.conf \
      --replace-fail '<dir prefix="cwd">fonts</dir>' "<dir>$out/fonts</dir>"
  '';

  unwrapped =
    let
      mach = buildMozillaMach {
        pname = "tor-browser";
        applicationName = "Tor Browser";
        binaryName = "tor-browser";
        # Version of the Firefox ESR base, used by buildMozillaMach to select
        # patches and toolchains. The derivation itself carries the Tor
        # Browser version.
        version = firefoxVersion;
        packageVersion = version;
        inherit src;

        branding = "browser/branding/tb-release";

        extraPostPatch = ''
          # The upstream source tarball does not ship sourcestamp.txt, which
          # buildMozillaMach uses to set a reproducible MOZ_BUILD_DATE. Use
          # the BuildID of the corresponding official build (see the
          # application.ini of the published tor-browser binaries).
          echo 20260720080000 > sourcestamp.txt
        '';
        # TODO: upstream also patches the geoip data

        # Configure flags modelled on the upstream mozconfigs
        # (browser/config/mozconfigs/{base-browser,tor-browser} and the
        # top-level mozconfig-linux-x86_64), adapted for a Nix build:
        # - The updater stays disabled; nixpkgs handles updates. (This also
        #   makes the updater-only options --disable-bspatch/--disable-zucchini
        #   unavailable, so unlike the upstream mozconfigs they are not passed.)
        # - --with-relative-data-dir is dropped so that profiles and tor
        #   state are not kept next to the (read-only) binaries in the
        #   Nix store. wrapFirefox installs the is-packaged-app marker,
        #   which makes the browser keep its state in ~/.tor project,
        #   just like the binary tor-browser package.
        extraConfigureFlags = [
          # Required by the tor-browser source tree.
          "--with-base-browser-version=${version}"
          # Official Tor Browser releases build with the release update
          # channel (also unsets TOR_BROWSER_NIGHTLY_BUILD).
          "--enable-update-channel=release"
          # Same application basename as the official builds (application.ini
          # Name=Firefox).
          "--with-app-basename=Firefox"
          # Fallback profile location (used if the is-packaged-app marker is
          # removed): ~/.torbrowser/firefox.
          "--with-user-appdir=.torbrowser"
          "--enable-rust-simd"
          "--disable-unverified-updates"
          "--disable-base-browser-update"
          "--enable-bundled-fonts"
          "--disable-parental-controls"
          "--enable-proxy-bypass-protection"
          "--disable-system-policies"
          "--disable-system-preferences"
          "--disable-backgroundtasks"
          "--disable-legacy-profile-creation"
          "MOZ_TELEMETRY_REPORTING="
        ];

        extraPassthru = {
          inherit torData;
        };

        meta = {
          description = "Privacy-focused browser routing traffic through the Tor network (built from source)";
          homepage = "https://www.torproject.org/";
          changelog = "https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/raw/maint-${lib.versions.majorMinor version}/projects/browser/Bundle-Data/Docs-TBB/ChangeLog.txt";
          license = with lib.licenses; [
            mpl20
            lgpl21Plus
            lgpl3Plus
            free
          ];
          platforms = lib.platforms.unix;
          maxSilent = 14400; # 4h, as for the other Mozilla browser builds
          mainProgram = "tor-browser";
        };
      };

      # Match the upstream base-browser configuration: no crash reporter,
      # no geolocation, no WebRTC and no EME (Widevine/Adobe CDMs).
      configured = mach.override {
        privacySupport = true;
        drmSupport = false;
        # PGO is disabled: the PGO profile server (build/pgo/profileserver.py)
        # hangs with the Tor Browser browser configuration - the profiling
        # run never loads the pages it serves locally, most likely because
        # the integrated tor-launcher/TorDomainIsolator machinery interferes
        # with direct (non-tor) connections. This was still reproducible with
        # network.proxy.type=0 and network.dns.disabled=false injected into
        # the profile server's test profile.
        pgoSupport = false;
      };
    in
    # The tor-browser source tree carries patches to the bundled
    # NSS/mozpkix (e.g. the ERROR_ONION_WITH_SELF_SIGNED_CERT result used
    # by security/certverifier), so the in-tree NSS must be built;
    # --with-system-nss (which implies --with-system-nspr) cannot work.
    configured.overrideAttrs (oldAttrs: {
      configureFlags = builtins.filter (
        flag: flag != "--with-system-nss" && flag != "--with-system-nspr"
      ) oldAttrs.configureFlags;
      # Extra branding/provenance settings to match the official builds;
      # appended after buildMozillaMach's preConfigure on purpose so they
      # take precedence.
      preConfigure = oldAttrs.preConfigure + ''
        # WM_CLASS / remoting name (buildMozillaMach sets it to binaryName).
        export MOZ_APP_REMOTINGNAME="Tor Browser"
        # Source info recorded in application.ini (the source tarball has no
        # VCS metadata; the changeset is the tag commit of the official build).
        export MOZ_INCLUDE_SOURCE_INFO=1
        export MOZ_SOURCE_REPO="https://gitlab.torproject.org/tpo/applications/tor-browser"
        export MOZ_SOURCE_CHANGESET="b98a4b6556beae53c84f445dfcc3d60784399c76"
      '';
    });
in
let
  wrapped = wrapFirefox unwrapped {
    pname = "tor-browser-from-src";
    wmClass = "tor-browser";
    icon = "tor-browser";
    extraPrefs = ''
      // Use the tor daemon from the nixpkgs tor package; no tor binary is
      // bundled with this build.
      lockPref("extensions.torlauncher.tor_path", "${tor}/bin/tor");
      lockPref("extensions.torlauncher.torrc-defaults_path", "${torData}/torrc-defaults");
    '';
  };
in
wrapped.overrideAttrs (old: {
  # The wrapper derivation uses a custom buildCommand, so phases like
  # postInstall never run; append to buildCommand instead.
  buildCommand = (old.buildCommand or "") + ''
    # The browser's bundled-font support reads <GREdir>/fonts (see
    # toolkit/xre/nsXREDirProvider.cpp and gfx/thebes/gfxFcPlatformFontList.cpp),
    # but the source tree only ships fonts.conf and TwemojiMozilla.ttf there,
    # so every glyph rendered as tofu. Install the full upstream font bundle.
    fontsDir="$out/lib/tor-browser/fonts"
    rm "$fontsDir/fonts.conf" "$fontsDir/TwemojiMozilla.ttf"
    ln -s "${bundledFonts}/fonts"/* "$fontsDir/"
  '';
  # Point fontconfig at the bundled fonts configuration even for processes
  # that have not (yet) gone through the browser's own startup, which sets
  # FONTCONFIG_PATH/FONTCONFIG_FILE itself (mirrors the binary tor-browser
  # package in nixpkgs).
  makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
    "--set"
    "FONTCONFIG_FILE"
    "${bundledFonts}/fonts/fonts.conf"
  ];
})
