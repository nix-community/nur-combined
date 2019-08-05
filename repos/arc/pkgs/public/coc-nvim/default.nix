{ fetchFromGitHub, yarn2nix, yarn, vimUtils }: let
  pname = "coc-nvim";
  version = "0.0.67";
  src = fetchFromGitHub {
    owner = "neoclide";
    repo = "coc.nvim";
    rev = "v${version}";
    sha256 = "0aqsgz76byqdddwk53gvyn20zk5xaw14dp2kjvl0v80801prqi93";
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

  configurePhase = ''
    mkdir -p node_modules
    ln -s ${deps}/node_modules/* node_modules/
    ln -s ${deps}/node_modules/.bin node_modules/
  '';

  buildPhase = ''
    ${yarn}/bin/yarn build
  '';

  postFixup = ''
    substituteInPlace $target/autoload/coc/util.vim \
      --replace "'yarnpkg'" "'${yarn}/bin/yarnpkg'"
    substituteInPlace $target/autoload/health/coc.vim \
      --replace "'yarnpkg'" "'${yarn}/bin/yarnpkg'"
  '';

  meta.broken = !(builtins.tryEval yarn2nix).success;
}
