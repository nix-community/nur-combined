{
  fetchFromForgejo,
  lib,
  nix-update-script,
  nushell,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "nu-plugin-bexpand";
  version = "1.3.11301+nu-0.113.1-unstable-2026-06-25";
  src = fetchFromForgejo {
    domain = "forge.axfive.net";
    owner = "Taylor";
    repo = "nu-plugin-bexpand";
    rev = "5f0c0b7f4a6855e4f8608683af7af49506a244eb";
    hash = "sha256-sSnIC0PoGOxS5/NenMcvSATAS+huTnHyJ/Xv/CibFrU=";
  };

  cargoHash = "sha256-VR1GHVcb8rL2nxEWKsC7AFu1msssMXeZlRh3GsAKkCw=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Bash style brace expansion for nushell";
    homepage = "https://forge.axfive.net/Taylor/nu-plugin-bexpand";
    license = lib.licenses.mpl20;
    inherit (nushell.meta) platforms;
    mainProgram = "nu_plugin_bexpand";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
