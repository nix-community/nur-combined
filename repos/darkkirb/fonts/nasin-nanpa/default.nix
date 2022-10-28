{
  stdenv,
  fontforge,
  fetchFromGitHub,
  lib,
  writeScript,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  version = builtins.fromJSON (builtins.readFile ./version.json);
in
  stdenv.mkDerivation {
    pname = "nasin-nanpa";
    version = "${version.minor}";
    src = fetchFromGitHub {
      owner = "ETBCOR";
      repo = "nasin-nanpa";
      inherit (source) rev sha256;
    };
    nativeBuildInputs = [fontforge];
    buildPhase = "fontforge -lang=ff -c 'Open($1); Generate($2)' \"ffversions/${version.major}/nasin-nanpa-${version.minor}.sfd\" \"nasin-nanpa.otf\"";
    installPhase = "install -m444 -Dt $out/share/fonts/opentype/nasin-nanpa nasin-nanpa.otf";
    meta = {
      description = "A font for sitelen pona";
      license = lib.licenses.mit;
    };
    passthru.updateScript = writeScript "update-nasin-nanpa" ''
      ${../../scripts/update-git.sh} https://github.com/ETBCOR/nasin-nanpa fonts/nasin-nanpa/source.json
      SRC_PATH=$(nix-build -E '(import ./. {}).nasin-nanpa.src')
      ls $SRC_PATH/ffversions/*/*.sfd | sort | tail -n1 | sed 's|[/-]| |g' | sed 's/.sfd//' | awk '{print "{\"major\": \"" $6 "\", \"minor\": \"" $9 "\"}" }' > fonts/nasin-nanpa/version.json
    '';
  }
