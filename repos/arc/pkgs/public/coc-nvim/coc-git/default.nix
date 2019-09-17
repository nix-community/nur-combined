{ fetchFromGitHub, yarn2nix, yarn, vimUtils }: let
  pname = "coc-git";
  version = "1.6.10";
  src = fetchFromGitHub {
    owner = "neoclide";
    repo = pname;
    rev = version;
    sha256 = "15r8gwsk69gg1p68jgi3gw0m29lbfs7iddcmhgr5qkrvk8rhhi1j";
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
