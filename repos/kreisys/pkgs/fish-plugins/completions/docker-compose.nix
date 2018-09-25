{ fetchurl, runCommand, packagePlugin }:

let
  name    = "docker-compose";
  version = "1.22.0";
  sha256  = "0751sy35dgrnf0pdjx1w2zan9gz40yky6nbysdn3m4q44z6rr7q0";

  src = runCommand "fish-completion-${name}-${version}-src" {
    src = fetchurl {
      url = "https://raw.githubusercontent.com/docker/compose/${version}/contrib/completion/fish/docker-compose.fish";
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
