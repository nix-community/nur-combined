{
  fetchFromGitHub,
  lib,
  nix-update-script,
  nushell,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu-plugin-file";
  version = "0.27.0";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_file";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TC5XlHSg4K+eJ5vu7Q1JAKPL7qTUfEWTP7CQY6wYzgg=";
  };

  cargoHash = "sha256-f3alP2QJRsZtzC5lk5qfl3Dlxs6Itw+rBPnj9HcEN4Q=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nushell plugin that will inspect a file and return information based on it's magic number";
    homepage = "https://github.com/fdncred/nu_plugin_file";
    license = lib.licenses.agpl3Plus;
    inherit (nushell.meta) platforms;
    mainProgram = "nu_plugin_file";
    maintainers = [ lib.maintainers.bandithedoge ];
    broken = true;
  };
})
