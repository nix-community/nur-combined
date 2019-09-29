{ fetchFromGitHub, yarn2nix, yarn, vimUtils, nodePackages }: let
  pname = "coc-nvim";
  version = "0.0.74";
  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc.nvim";
    rev = "bc017b02e6";
    sha256 = "0z9jjflbl8ib2k6jzfrz9a90wivnhwpdarp497bh6g9bl17xby9b";
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

    # fragile :(
    substituteInPlace webpack.config.js \
      --replace "/Users/chemzqm/.config/yarn/global/node_modules/" "" \
      --replace "git rev-parse HEAD" "echo $version" \
      --replace "res.slice(0, 10)" "res"
  '';

  buildPhase = ''
    yarn build

    webpack-cli
    rm -r node_modules
  '';

  meta.broken = !(builtins.tryEval yarn2nix).success;
}
