{ fetchFromGitHub, yarn2nix, yarn, vimUtils, nodePackages, fetchpatch }: let
  pname = "coc-rust-analyzer";
  version = "0.7.13";
  src = fetchFromGitHub {
    owner = "fannheyward";
    repo = pname;
    rev = "d2d3060";
    sha256 = "1dmrfykcg4rbdyv6kbmipmq2vclpd0h1xbfd4290j1vpj6clhabj";
  };
  deps = yarn2nix.mkYarnModules rec {
    inherit pname version;
    name = "${pname}-modules-${version}";
    packageJSON = src + "/package.json";
    yarnLock = src + "/yarn.lock";
    yarnNix = ./yarn.nix;
  };
in vimUtils.buildVimPluginFrom2Nix {
  inherit version pname src;

  patches = [
    ./be-quiet.patch
  ];

  nativeBuildInputs = with nodePackages; [ webpack-cli yarn ];
  NODE_PATH = "${nodePackages.webpack}/lib/node_modules";

  configurePhase = ''
    mkdir -p node_modules
    ln -s ${deps}/node_modules/* node_modules/
    ln -s ${deps}/node_modules/.bin node_modules/
  '';

  buildPhase = ''
    yarn build

    webpack-cli
    rm -r node_modules
  '';

  meta.broken = !(builtins.tryEval yarn2nix).success || yarn.stdenv.isDarwin;
}
