{ fetchFromGitHub, yarn2nix, yarn, vimUtils, nodePackages, fetchpatch }: let
  pname = "coc-rust-analyzer";
  version = "0.10.1";
  src = fetchFromGitHub {
    owner = "fannheyward";
    repo = pname;
    rev = "8a1ec55558f201b85536ca572d89ef486676f2ed";
    sha256 = "0gbr08r86xh3yx6vrqwzips0c0j6w3ssa0hnqb0y8a96728q5sfk";
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
