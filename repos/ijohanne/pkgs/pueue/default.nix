{ sources, lib, rustPlatform, fetchFromGitHub, installShellFiles }:
rustPlatform.buildRustPackage rec {
  pname = "pueue";
  version = "master";
  src = fetchFromGitHub { inherit (sources.pueue) owner repo rev sha256; };

  cargoSha256 = "00lsqd9slp79q8xkv4pf76gq8kaa9pvmicp44yyrc9l25mhvr19s";

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  postInstall = ''
    # zsh completion generation fails. See: https://github.com/Nukesor/pueue/issues/57
    for shell in bash fish; do
      $out/bin/pueue completions $shell .
      installShellCompletion pueue.$shell
    done
  '';

  meta = with lib; {
    description = "A daemon for managing long running shell commands";
    homepage = "https://github.com/Nukesor/pueue";
    license = licenses.mit;
  };
}
