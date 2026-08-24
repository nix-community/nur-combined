{
  fetchFromGitHub,
  lib,
  nix-update-script,
  nushell,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu-plugin-regex";
  version = "0.24.0";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_regex";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AQzpqv8gBwM3k4Qs6lLha6MBZb7kp2tu5lQImSQNnIg=";
  };

  cargoHash = "sha256-YsYmKpqCtDtDscdgdISVwHz4sJGId9+9hXkrm95sQM0=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nushell plugin to search text with regular expressions";
    homepage = "https://github.com/fdncred/nu_plugin_regex";
    license = lib.licenses.mit;
    inherit (nushell.meta) platforms;
    mainProgram = "nu_plugin_regex";
    maintainers = [ lib.maintainers.bandithedoge ];
    broken = true;
  };
})
