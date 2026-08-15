{
  lib,
  fetchFromGitHub,
  php,
  conf ? null,
}:

php.buildComposerProject (finalAttrs: {
  pname = "level0";
  version = "2026-03-08";

  src = fetchFromGitHub {
    owner = "Zverik";
    repo = "Level0";
    rev = "3346f1b60e32a4d0913bd03342c56b43b1e9bf75";
    hash = "sha256-jzF9LlOsLTlp3+VS3E+CZ5hNsKgv2c0o4O4OkLuqIuA=";
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
