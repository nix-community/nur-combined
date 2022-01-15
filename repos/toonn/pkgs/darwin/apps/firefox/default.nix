{ stdenv, lib, callPackage, fetchurl, undmg
, version ? "latest"
}:
let versions = callPackage (import ./versions.nix) {};
    versionSpecific = versions."${version}";
in stdenv.mkDerivation rec {
  inherit (versionSpecific) version;

  name = "firefox-app-${version}";

  pname = "Firefox";

  src = fetchurl {
    inherit (versionSpecific) sha256;
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
    name = "${name}.dmg";
  };

  buildInputs = [ undmg ];

  # The dmg contains the app and a symlink, the default unpackPhase tries to cd
  # into the only directory produced so it fails.
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    mv ${pname}.app $out/Applications
    '';

  meta = {
    description = "Mozilla Firefox, free web browser (binary package)";
    homepage = "http://www.mozilla.org/firefox/";
    license = {
      free = false;
      url = "http://www.mozilla.org/en-US/foundation/trademarks/policy/";
    };
    maintainers = with lib.maintainers; [ toonn ];
    platforms = [ "x86_64-darwin" ];
  };
}
