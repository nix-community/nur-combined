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

  fetchAddon = name: extid: hash: fetchurl {
    inherit name hash;
    url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
    # extid can be found by unar'ing the above xpi, and copying browser_specific_settings.gecko.id field
    passthru = { inherit extid; };
  };
in lib.makeScope newScope (self: with self; {
  unwrapped = lib.recurseIntoAttrs {
    # get names from:
    # - ~/ref/nix-community/nur-combined/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
    # `wget ...xpi`; `unar ...xpi`; `cat */manifest.json | jq '.browser_specific_settings.gecko.id'`
    #
    # TODO: give these updateScript's
    browserpass-extension = callPackage ./browserpass-extension { };
    bypass-paywalls-clean = callPackage ./bypass-paywalls-clean { };
    ether-metamask = fetchAddon "ether-metamask" "webextension@metamask.io"
      "sha256-MFb68cPM/tQ3+b3mx2doMaXX3FiAiMOttHu8zL/9BbY=";
    i2p-in-private-browsing = fetchAddon "i2p-in-private-browsing" "i2ppb@eyedeekay.github.io"
      "sha256-aS8Alj/UNgcTp/TDWPN69wSn0GxDsQx44dtxrybdPXo=";
    sidebery = fetchAddon "sidebery" "{3c078156-979c-498b-8990-85f7987dd929}"
      "sha256-9ZJCehxo0+Ua7iCNBViPOXAklpV3cf2Et2qT42QTi/U=";
    ublacklist = fetchAddon "ublacklist" "@ublacklist"
      "sha256-diKkwxe1C35wsGNQd0yHh9BenPRSmGiRmCdmnW8sTD4=";
    ublock-origin = fetchAddon "ublock-origin" "uBlock0@raymondhill.net"
      "sha256-OTJQbOTfMG5Np1J9k9YP4EIc8VBFwvTqc1idmgkCJms=";

    sponsorblock = stdenv.mkDerivation rec {
      pname = "sponsorblock";
      version = "5.4.21";
      src = fetchurl {
        url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/FirefoxSignedInstaller.xpi";
        hash = "sha256-mfCHD46FgmCQ8ugg58ML19zIllBQEJthfheTrEObs7M=";
      };

      dontUnpack = true;
      installPhase = ''
        cp $src $out
      '';

      passthru.updateScript = nix-update-script { };
      passthru.extid = "sponsorBlocker@ajay.app";
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
