{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  conf ? null,
}:

stdenvNoCC.mkDerivation rec {
  pname = "level0";
  version = "2021-06-08";

  src = fetchFromGitHub {
    owner = "Zverik";
    repo = "Level0";
    rev = "fa92855bce868bc7f5f8d3c1510985d97db1e3b8";
    hash = "sha256-IendoFItO8w9z1HdDh9Z6vLvPrDRFRtYsLhOrIqDezM=";
  };

  postPatch = ''
    substituteInPlace locales/deploy_locales \
      --replace-fail "../www" "$out/www" \
      --replace-fail "source " "#source "
  '';

  configFile = lib.optionalString (conf != null) (builtins.toFile "config.php" conf);
  preBuild = lib.optionalString (conf != null) "cp ${configFile} www/config.php";

  installPhase = ''
    mkdir -p $out
    cp -r www $out/www
    (cd locales; ./deploy_locales)
  '';

  meta = {
    description = "Web-based OpenStreetMap Editor";
    inherit (src.meta) homepage;
    license = lib.licenses.wtfpl;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
