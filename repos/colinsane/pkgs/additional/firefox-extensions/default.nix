{ stdenv
, browserpass-extension
, fetchFirefoxAddon
, jq
, strip-nondeterminism
, unzip
, writeScript
, zip
}:
let
  # given an addon, repackage it without some `perm`ission
  removePermission = perm: addon:
  let
    extid = addon.passthru.extid;
  in stdenv.mkDerivation {
    # heavily borrows from <repo:nixos/nixpkgs:pkgs/build-support/fetchfirefoxaddon/default.nix>
    inherit (addon) name;
    passthru = {
      inherit extid;
      original = addon;
    };
    builder = writeScript "manifest-fixer" ''
      source $stdenv/setup

      UUID="${extid}"
      echo "firefox addon $name into $out/$UUID.xpi, remove ${perm}"

      # extract the XPI
      mkdir -p "$out/$UUID"
      unzip -q "${addon}/$UUID.xpi" -d "$out/$UUID"

      # apply the operation
      NEW_MANIFEST=$(jq 'del(.permissions[] | select(. == "${perm}"))' "$out/$UUID/manifest.json")
      echo "$NEW_MANIFEST" > "$out/$UUID/manifest.json"

      # repackage the XPI
      cd "$out/$UUID"
      zip -r -q -FS "$out/$UUID.xpi" *
      strip-nondeterminism "$out/$UUID.xpi"
      rm -r "$out/$UUID"
    '';

    nativeBuildInputs = [
      jq
      strip-nondeterminism
      unzip
      zip
    ];
  };
  # given an addon, add a `passthru.withoutPermission` method for further configuration
  mkConfigurable = pkg: pkg.overrideAttrs (final: upstream: {
    passthru = (upstream.passthru or {}) // {
      withoutPermission = perm: mkConfigurable (removePermission perm final.finalPackage);
    };
  });

  addon = name: extid: hash: mkConfigurable (fetchFirefoxAddon {
    inherit name hash;
    url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
    # extid can be found by unar'ing the above xpi, and copying browser_specific_settings.gecko.id field
    fixedExtid = extid;
  });
  localAddon = pkg: mkConfigurable (fetchFirefoxAddon {
    inherit (pkg) name;
    src = "${pkg}/share/mozilla/extensions/\\{ec8030f7-c20a-464f-9b0e-13a3a9e97384\\}/${pkg.extid}.xpi";
    fixedExtid = pkg.extid;
  });
in {
  # get names from:
  # - ~/ref/nix-community/nur-combined/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
  # `wget ...xpi`; `unar ...xpi`; `cat */manifest.json | jq '.browser_specific_settings.gecko.id'`
  #
  # TODO: give these updateScript's

  browserpass-extension = localAddon browserpass-extension;

  # TODO: build bypass-paywalls from source? it's mysteriously disappeared from the Mozilla store.
  # bypass-paywalls-clean.package = addon "bypass-paywalls-clean" "{d133e097-46d9-4ecc-9903-fa6a722a6e0e}" "sha256-oUwdqdAwV3DezaTtOMx7A/s4lzIws+t2f08mwk+324k=";
  # bypass-paywalls-clean.enable = lib.mkDefault true;

  # TODO: give these update scripts, make them reachable via `pkgs`
  ether-metamask = addon "ether-metamask" "webextension@metamask.io" "sha256-UI83wUUc33OlQYX+olgujeppoo2D2PAUJ+Wma5mH2O0=";
  i2p-in-private-browsing = addon "i2p-in-private-browsing" "i2ppb@eyedeekay.github.io" "sha256-dJcJ3jxeAeAkRvhODeIVrCflvX+S4E0wT/PyYzQBQWs=";
  sidebery = addon "sidebery" "{3c078156-979c-498b-8990-85f7987dd929}" "sha256-YONfK/rIjlsrTgRHIt3km07Q7KnpIW89Z9r92ZSCc6w=";
  sponsorblock = addon "sponsorblock" "sponsorBlocker@ajay.app" "sha256-b/OTFmhSEUZ/CYrYCE4rHVMQmY+Y78k8jSGMoR8vsZA=";
  ublacklist = addon "ublacklist" "@ublacklist" "sha256-NZ2FmgJiYnH7j2Lkn0wOembxaEphmUuUk0Ytmb0rNWo=";
  ublock-origin = addon "ublock-origin" "uBlock0@raymondhill.net" "sha256-EGGAA+cLUow/F5luNzFG055rFfd3rEyh8hTaL/23pbM=";
}
