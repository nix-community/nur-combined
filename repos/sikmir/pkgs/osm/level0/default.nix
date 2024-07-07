{
  lib,
  fetchFromGitHub,
  php,
  conf ? null,
}:

php.buildComposerProject (finalAttrs: {
  pname = "level0";
  version = "2024-06-24";

  src = fetchFromGitHub {
    owner = "Zverik";
    repo = "Level0";
    rev = "390c8108c3cd7c7599129542ea48ed6f792213d1";
    hash = "sha256-4gp3E4FdHAZX+PCi+v+f0cTVhB2MqkkIcGAQrXQqLZg=";
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
