{
  fetchFromGitHub,
  lib,
  nix-update-script,
  nushell,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "nu-plugin-mime";
  version = "0-unstable-2026-08-22";
  src = fetchFromGitHub {
    owner = "kik4444";
    repo = "nu_plugin_mime";
    rev = "4da5772baf4f2a1d0b515151f70414430e57b2ec";
    sha256 = "sha256-WN4HGaPrkrwJwkhTueWPK2a2JZKNJzKw73gci+8VUXM=";
  };

  cargoHash = "sha256-qWwvweYgApGPoZuFnw8ibq8RWLbvwOCsDQCIsJ/U6u0=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Nushell plugin for working with mime types without performing disk access";
    homepage = "https://github.com/kik4444/nu_plugin_mime";
    license = lib.licenses.mit;
    inherit (nushell.meta) platforms;
    mainProgram = "nu_plugin_mime";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
