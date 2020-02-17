{ fetchFromGitHub, yarn2nix, yarn, vimUtils, nodePackages }: let
  pname = "coc-rls";
  version = "1.1.4";
  src = fetchFromGitHub {
    owner = "neoclide";
    repo = pname;
    rev = version;
    sha256 = "18d2pxmifyacg7gki99bja7gjs7ycprsm3p6p7snf3dx3g5r4pqq";
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
