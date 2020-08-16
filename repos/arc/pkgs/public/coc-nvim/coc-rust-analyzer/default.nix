{ fetchFromGitHub, yarn2nix, yarn, vimUtils, nodePackages, fetchpatch }: let
  pname = "coc-rust-analyzer";
  version = "0.7.14";
  src = fetchFromGitHub {
    owner = "fannheyward";
    repo = pname;
    rev = "4bb4ad7b0f0e10d9e25f81683b15c802652e3f23";
    sha256 = "1bcj5fq74kzc5a2f3shzc15yzprjsrr8nrlgilssmjjj4ykqgcr1";
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
