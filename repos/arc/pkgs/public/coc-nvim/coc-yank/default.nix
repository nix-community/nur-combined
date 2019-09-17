{ fetchFromGitHub, yarn2nix, yarn, vimUtils }: let
  pname = "coc-yank";
  version = "1.1.2";
  src = fetchFromGitHub {
    owner = "neoclide";
    repo = pname;
    rev = version;
    sha256 = "1pw1p3h2aqlldwl9qbiin7a1yzjl04i3dm6s86bpjhl1ixwkj3by";
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
