{ sources, lib, rustPlatform, fetchFromGitHub, installShellFiles }:
rustPlatform.buildRustPackage rec {
  pname = "pueue";
  version = "master";
  src = fetchFromGitHub { inherit (sources.pueue) owner repo rev sha256; };

  cargoSha256 = "03m354dr0hgym9snmd75274nszmbspcad1zw1g25bikfv91gf03z";

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
