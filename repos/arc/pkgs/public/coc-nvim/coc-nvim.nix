{ fetchFromGitHub, yarn2nix, yarn, vimUtils }: let
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
