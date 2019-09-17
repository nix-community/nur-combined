{ fetchFromGitHub, yarn2nix, yarn, vimUtils }: let
  pname = "coc-rust-analyzer";
  version = "2019-09-16";
  src = fetchFromGitHub {
    owner = "fannheyward";
    repo = pname;
    rev = "520b9e3";
    sha256 = "091bb3l5fdhhp2dqisjz64flfhylz9sn34mfv20z93b0cfzcvjs1";
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

  meta.broken = !(builtins.tryEval yarn2nix).success;
}
