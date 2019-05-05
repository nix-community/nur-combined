{ pkgs, lib, firefox, wrapFirefox, stdenv, fetchurl, unzip, lndir, makeWrapper, wrapGAppsHook, makeDesktopItem
  , userSettings ? {}
  , userPolicies ? {}
 }:

let
  version = firefox.unwrapped.version;

  settingsJson = builtins.fromJSON (lib.readFile ./settings.json) // userSettings;
  autoconfigJs = pkgs.writeText "autoconfig.js" ''
pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);
'';

  policiesJson = builtins.fromJSON (lib.readFile ./policies.json) ;
  updatedPolicies = { "policies" = policiesJson.policies // userPolicies ; };

  policiesFile = pkgs.writeText "policies.json" (builtins.toJSON updatedPolicies);

  mozillaCfg = pkgs.writeText "mozilla.cfg" ''
${lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value: ''lockPref( ${(builtins.toJSON key)} , ${(builtins.toJSON value)} );'') settingsJson)}
'';

  userFoxUnwrapped = stdenv.mkDerivation {
    name = "UserFox-unwrapped-${version}";
    version = version;

    passthru = firefox.unwrapped.passthru // {
      browserName = "userfox";
    };

    buildInputs = [ makeWrapper ];
    nativeBuildInputs = [ lndir wrapGAppsHook ];

    phases = [ "installPhase" "fixupPhase"];

    installPhase = ''
      mkdir -p $out $out/bin $out/lib/userfox/

      lndir ${firefox.unwrapped}/lib/firefox $out/lib/userfox

      rm $out/lib/userfox/firefox $out/lib/userfox/firefox-bin
      cp ${firefox.unwrapped}/lib/firefox/firefox $out/lib/userfox/userfox
      cp ${firefox.unwrapped}/lib/firefox/firefox-bin $out/lib/userfox/userfox-bin


      ln -s ${mozillaCfg} $out/lib/userfox/mozilla.cfg
      ln -s ${autoconfigJs} $out/lib/userfox/defaults/pref/autoconfig.js

      mkdir $out/lib/userfox/distribution
      ln -s ${policiesFile} $out/lib/userfox/distribution/policies.json

      ln -s $out/lib/userfox/userfox $out/bin/userfox
    '';

    meta = firefox.unwrapped.meta;
  };

  userfox = wrapFirefox userFoxUnwrapped {};
in userfox
