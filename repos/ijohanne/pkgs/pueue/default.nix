{ sources, lib, rustPlatform, fetchFromGitHub, installShellFiles }:
rustPlatform.buildRustPackage rec {
  pname = "pueue";
  version = "master";
  src = fetchFromGitHub { inherit (sources.pueue) owner repo rev sha256; };

  cargoSha256 = "1yik4w6xl6hgx3h07n5scx3rhrqkzgapkbbr3v2krgdqlwvk17rq";

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
