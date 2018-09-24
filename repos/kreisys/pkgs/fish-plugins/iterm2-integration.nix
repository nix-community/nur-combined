{ fetchurl, runCommand, packagePlugin }:

let
  name    = "iterm2-integration";
  version = "3.2.0";
  sha256  = "19sw6jq4idwy4ask0bsww599nd5f98miym9zqp7rj8p2sx4wl63f";

  src = runCommand "fish-plugin-${name}-${version}-src" {
    src = fetchurl {
      url = "https://raw.githubusercontent.com/gnachman/iterm2-website/v${version}/source/shell_integration/fish";
      inherit sha256;
    };
  } ''
    mkdir -p $out/conf.d
    cp $src $out/conf.d/${name}.fish
  '';
in packagePlugin {
  inherit src;
  name = "${name}-${version}";
}
