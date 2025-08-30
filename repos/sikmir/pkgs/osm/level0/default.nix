{
  lib,
  fetchFromGitHub,
  php,
  conf ? null,
}:

php.buildComposerProject (finalAttrs: {
  pname = "level0";
  version = "2025-07-17";

  src = fetchFromGitHub {
    owner = "Zverik";
    repo = "Level0";
    rev = "90966b7346e7086db178da0c610fb15bf4831339";
    hash = "sha256-VbufWA4pl4+6jOcaLQ5AZFhWKFoOKlcZFEuRbLJq4TQ=";
  };

  vendorHash = "sha256-+49ednqEuhTNO6t20SdkSYYSL9v8QNehxVWLgCuJWW0=";

  configFile = lib.optionalString (conf != null) (builtins.toFile "config.php" conf);
  preBuild = lib.optionalString (conf != null) "cp ${finalAttrs.configFile} www/config.php";

  meta = {
    description = "Web-based OpenStreetMap Editor";
    homepage = "https://github.com/Zverik/Level0";
    license = lib.licenses.wtfpl;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
