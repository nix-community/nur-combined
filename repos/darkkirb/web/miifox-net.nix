{
  stdenvNoCC,
  fetchFromGitea,
  chevron,
  lndir,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./miifox.json);
in
  stdenvNoCC.mkDerivation {
    pname = "miifox.net";
    version = source.date;
    src = fetchFromGitea {
      domain = "git.chir.rs";
      owner = "CarolineHusky";
      repo = "MiiFox.net";
      inherit (source) rev sha256;
    };
    nativeBuildInputs = [chevron lndir];
    buildPhase = ''
      chevron -d index.json index.handlebars > index.html
    '';
    installPhase = ''
      mkdir $out
      lndir -silent $src $out
      cp index.html $out
      rm $out/index.json
    '';
    meta = {
      description = "miifox.net";
      license = lib.licenses.unfree;
    };
    passthru.updateScript = [../scripts/update-git.sh "https://git.chir.rs/CarolineHusky/MiiFox.net" "web/miifox.json"];
  }
