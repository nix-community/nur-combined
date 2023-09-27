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
      NEW_MANIFEST=$(jq '. + {"applications": { "gecko": { "id": "${extid}" }}, "browser_specific_settings":{"gecko":{"id": "${extid}"}}}' manifest.json)
      echo "$NEW_MANIFEST" > manifest.json

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
      withAttrs = attrs: wrapAddon addon (args // attrs);
      withPostPatch = postPatch: final.passthru.withAttrs { inherit postPatch; };
      # given an addon, repackage it without some `perm`ission
      withoutPermission = perm: final.passthru.withPostPatch ''
        NEW_MANIFEST=$(jq 'del(.permissions[] | select(. == "${perm}"))' manifest.json)
        echo "$NEW_MANIFEST" > manifest.json
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

    passthru.updateScript = nix-update-script { };
    passthru.extid = extid;
  };

in lib.makeScope newScope (self: with self; {
  unwrapped = lib.recurseIntoAttrs {
    # get names from:
    # - ~/ref/nix-community/nur-combined/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
    # `wget ...xpi`; `unar ...xpi`; `cat */manifest.json | jq '.browser_specific_settings.gecko.id'`
    browserpass-extension = callPackage ./browserpass-extension { };
    bypass-paywalls-clean = callPackage ./bypass-paywalls-clean { };

    ether-metamask = fetchVersionedAddon rec {
      extid = "webextension@metamask.io";
      pname = "ether-metamask";
      url = "https://github.com/MetaMask/metamask-extension/releases/download/v${version}/metamask-firefox-${version}.zip";
      version = "11.1.0";
      hash = "sha256-Rcm5lC2yKs4ghxF05WYNhSdVQ+VX0uog7h2lLYJeai8=";
    };
    i2p-in-private-browsing = fetchVersionedAddon rec {
      extid = "i2ppb@eyedeekay.github.io";
      pname = "i2p-in-private-browsing";
      url = "https://github.com/eyedeekay/I2P-in-Private-Browsing-Mode-Firefox/releases/download/${version}/i2ppb@eyedeekay.github.io.xpi";
      version = "1.47";
      hash = "sha256-LnR5z3fqNJywlr/khFdV4qloKGQhbxNZQvWCEgz97DU=";
    };
    sidebery = fetchVersionedAddon rec {
      extid = "{3c078156-979c-498b-8990-85f7987dd929}";
      pname = "sidebery";
      # N.B.: unsure if this URL format is stable
      url = "https://github.com/mbnuqw/sidebery/releases/download/v${version}/sidebery-${version}-unsigned.zip";
      version = "5.0.0";
      hash = "sha256-tHTU/l8ct+tY1/H+nZf3VlMlwoYn68+0pgeuFzm91XY=";
    };
    sponsorblock = fetchVersionedAddon rec {
      extid = "sponsorBlocker@ajay.app";
      pname = "sponsorblock";
      url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/FirefoxSignedInstaller.xpi";
      version = "5.4.21";
      hash = "sha256-mfCHD46FgmCQ8ugg58ML19zIllBQEJthfheTrEObs7M=";
    };
    ublacklist = fetchVersionedAddon rec {
      extid = "@ublacklist";
      pname = "ublacklist";
      url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-firefox.zip";
      version = "8.3.5";
      hash = "sha256-NAUkRXzFgwnIyP+uPAccQZUuHHxYFZakxrfMvp2yftg=";
    };
    ublock-origin = fetchVersionedAddon rec {
      extid = "uBlock0@raymondhill.net";
      pname = "ublock-origin";
      # N.B.: a handful of versions are released unsigned
      # url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.signed.xpi";
      url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.firefox.signed.xpi";
      version = "1.52.3b0";
      hash = "sha256-6idJQXOguCPXgs1RP6mKUjZK3lzSAkjvpDPVcWUfacI=";
    };
  };

  browserpass-extension = (wrapAddon unwrapped.browserpass-extension {})
    .withoutPermission "notifications";

  bypass-paywalls-clean = wrapAddon unwrapped.bypass-paywalls-clean {};
  ether-metamask = wrapAddon unwrapped.ether-metamask {};
  i2p-in-private-browsing = wrapAddon unwrapped.i2p-in-private-browsing {};
  sidebery = wrapAddon unwrapped.sidebery {};
  sponsorblock = (wrapAddon unwrapped.sponsorblock {})
    .withPostPatch ''
      # patch sponsorblock to not show the help tab on first launch.
      #
      # XXX: i tried to build sponsorblock from source and patch this *before* it gets webpack'd,
      # but web shit is absolutely cursed and building from source requires a fucking PhD
      # (if you have one, feel free to share your nix package)
      #
      # NB: in source this is `if (!userID)...`, but the build process mangles the names
      substituteInPlace js/background.js \
        --replace 'default.config.userID)' 'default.config.userID && false)'
    '';

  ublacklist = wrapAddon unwrapped.ublacklist {};
  ublock-origin = wrapAddon unwrapped.ublock-origin {};
})
