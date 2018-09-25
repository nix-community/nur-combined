{ fetchurl, runCommand, packagePlugin }:

let
  name    = "docker";
  version = "18.06.1-ce";
  sha256  = "07wrv05wxis5wxjr0716lfpdqisp295k94xf85avhdparqwqa117";

  src = runCommand "fish-completion-${name}-${version}-src" {
    src = fetchurl {
      url = "https://raw.githubusercontent.com/docker/cli/v${version}/contrib/completion/fish/docker.fish";
      inherit sha256;
    };
  } ''
    mkdir -p $out/completions
    cp $src $_/${name}.fish
  '';
in packagePlugin {
  inherit src;
  name = "${name}-completion-${version}";
}
