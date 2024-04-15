{ stdenv
, callPackage
, fetchurl
, gnused
, jq
, lib
, newScope
, nix-update-script
, strip-nondeterminism
, unzip
, writeScript
, zip
}:
let
  wrapAddon = addon: args:
  let
    extid = addon.passthru.extid;
    # merge our requirements into the derivation args
    args' = args // {
      passthru = {
        inherit extid;
        original = addon;
      } // (args.passthru or {});
      nativeBuildInputs = [
        jq
        strip-nondeterminism
        unzip
        zip
      ] ++ (args.nativeBuildInputs or []);
    };
  in (stdenv.mkDerivation ({
    # heavily borrows from <repo:nixos/nixpkgs:pkgs/build-support/fetchfirefoxaddon/default.nix>
    name = "${addon.name}-wrapped";
    unpackPhase = ''
      echo "patching firefox addon $name into $out/${extid}.xpi"

      mkdir build
      cd build
      # extract the XPI into the build directory
      # it could be already wrapped, or a raw fetchurl result
      unzip -q "${addon}/${extid}.xpi" -d . || \
        unzip -q "${addon}" -d .
    '';

    patchPhase = ''
      runHook prePatch

      # firefox requires addons to have an id field when sideloading:
      # - <https://extensionworkshop.com/documentation/publish/distribute-sideloading/>
      for m in manifest.json manifest_v2.json manifest_v3.json; do
        if test -e "$m"; then
          NEW_MANIFEST=$(jq '. + {"applications": { "gecko": { "id": "${extid}" }}, "browser_specific_settings":{"gecko":{"id": "${extid}"}}}' "$m")
          echo "$NEW_MANIFEST" > "$m"
        fi
      done

      runHook postPatch
    '';

    installPhase = ''
      runHook preInstall

      # repackage the XPI
      mkdir "$out"
      zip -r -q -FS "$out/${extid}.xpi" ./*
      strip-nondeterminism "$out/${extid}.xpi"

      runHook postInstall
    '';
  } // args')).overrideAttrs (final: upstream: {
    passthru = (upstream.passthru or {}) // {
      unwrapped = addon;
      withAttrs = attrs: wrapAddon addon (args // attrs);
      withPostPatch = postPatch: final.passthru.withAttrs { inherit postPatch; };
      # given an addon, repackage it without some `perm`ission
      withoutPermission = perm: final.passthru.withPostPatch ''
        for m in manifest.json manifest_v2.json manifest_v3.json; do
          if test -e "$m"; then
            NEW_MANIFEST=$(jq 'del(.permissions[] | select(. == "${perm}"))' "$m")
            echo "$NEW_MANIFEST" > "$m"
          fi
        done
      '';
    };
  });

  # fetchAddon: fetch an addon directly from the mozilla store.
  #             prefer NOT to use this, because moz store doesn't offer versioned release access
  #             which breaks caching/reproducibility and such.
  #             (maybe the `latest.xpi` URL redirects to a versioned URI visible if i used curl?)
  # fetchAddon = name: extid: hash: fetchurl {
  #   inherit name hash;
  #   url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
  #   # extid can be found by unar'ing the above xpi, and copying browser_specific_settings.gecko.id field
  #   passthru = { inherit extid; };
  # };

  fetchVersionedAddon = { extid, version, url, hash ? "", pname ? extid }: stdenv.mkDerivation {
    inherit pname version;
    src = fetchurl {
      inherit url hash;
    };
    dontUnpack = true;
    installPhase = ''
      cp $src $out
    '';

    passthru.updateScript = nix-update-script {
      extraArgs = [
        # uBlock mixes X.YY.ZbN and X.YY.ZrcN style.
        # default nix-update accepts the former but rejects the later as unstable.
        # that's problematic because beta releases later get pulled.
        # ideally i'd reject both, but i don't know how.
        "--version=unstable"
      ];
    };
    passthru.extid = extid;
  };

in (lib.makeScope newScope (self: with self; {
  unwrapped = lib.recurseIntoAttrs {
    # get names from:
    # - ~/ref/nix-community/nur-combined/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
    # `wget ...xpi`; `unar ...xpi`; `cat */manifest.json | jq '.browser_specific_settings.gecko.id'`
    browserpass-extension = callPackage ./browserpass-extension { };
    bypass-paywalls-clean = callPackage ./bypass-paywalls-clean { };
    ctrl-shift-c-should-copy = callPackage ./ctrl-shift-c-should-copy { };
    i-still-dont-care-about-cookies = callPackage ./i-still-dont-care-about-cookies { };
    open-in-mpv = callPackage ./open-in-mpv { };
    sidebery = callPackage ./sidebery { };

    ether-metamask = fetchVersionedAddon rec {
      extid = "webextension@metamask.io";
      pname = "ether-metamask";
      url = "https://github.com/MetaMask/metamask-extension/releases/download/v${version}/metamask-firefox-${version}.zip";
      version = "11.14.0";
      hash = "sha256-VXfJndT+MDEPbIJGjyCxdbMtwPRojgxjwQdY59ygZGc=";
    };
    fx_cast = fetchVersionedAddon rec {
      extid = "fx_cast@matt.tf";
      pname = "fx_cast";
      url = "https://github.com/hensm/fx_cast/releases/download/v${version}/fx_cast-${version}.xpi";
      version = "0.3.1";
      hash = "sha256-zaYnUJpJkRAPSCpM3S20PjMS4aeBtQGhXB2wgdlFkSQ=";
    };
    i2p-in-private-browsing = fetchVersionedAddon rec {
      extid = "i2ppb@eyedeekay.github.io";
      pname = "i2p-in-private-browsing";
      url = "https://github.com/eyedeekay/I2P-in-Private-Browsing-Mode-Firefox/releases/download/${version}/i2ppb@eyedeekay.github.io.xpi";
      version = "1.49";
      hash = "sha256-LnR5z3fqNJywlr/khFdV4qloKGQhbxNZQvWCEgz97DU=";
    };
    sponsorblock = fetchVersionedAddon rec {
      extid = "sponsorBlocker@ajay.app";
      pname = "sponsorblock";
      url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/FirefoxSignedInstaller.xpi";
      version = "5.5.9";
      hash = "sha256-lyBrszbjdfMOWZbYwE6DjNtM8wq0Vv1eCcobBKNelWw=";
    };
    ublacklist = fetchVersionedAddon rec {
      extid = "@ublacklist";
      pname = "ublacklist";
      url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-firefox.zip";
      version = "8.5.1";
      hash = "sha256-GLBB/in/RY2AQWph7/O5cQQEXZN9W9tJS/kqUD2IEck=";
    };
    ublock-origin = fetchVersionedAddon rec {
      extid = "uBlock0@raymondhill.net";
      pname = "ublock-origin";
      # N.B.: a handful of versions are released unsigned
      # url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.signed.xpi";
      url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.firefox.signed.xpi";
      version = "1.57.3b3";
      hash = "sha256-mwSikDhqNt7h6CMOowooaxrEpZca62YDmOhmC72K9co=";
    };
  };
})).overrideScope (self: super:
  let
    wrapped = lib.mapAttrs (name: _value: wrapAddon self.unwrapped."${name}" {}) super.unwrapped;
  in wrapped // {
    browserpass-extension = wrapped.browserpass-extension.withoutPermission "notifications";
    sponsorblock = wrapped.sponsorblock.withPostPatch ''
      # patch sponsorblock to not show the help tab on first launch.
      #
      # XXX: i tried to build sponsorblock from source and patch this *before* it gets webpack'd,
      # but web shit is absolutely cursed and building from source requires a fucking PhD
      # (if you have one, feel free to share your nix package)
      #
      # NB: in source this is `alreadyInstalled: false`, but the build process hates Booleans or something
      # TODO(2024/03/23): this is broken (replacement doesn't match). but maybe not necessary anymore?
      substituteInPlace js/*.js \
        --replace 'alreadyInstalled:!1' 'alreadyInstalled:!0'
    '';
  }
)
