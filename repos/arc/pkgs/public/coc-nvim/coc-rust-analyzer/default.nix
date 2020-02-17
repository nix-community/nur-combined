{ fetchFromGitHub, yarn2nix, yarn, vimUtils, nodePackages, fetchpatch }: let
  pname = "coc-rust-analyzer";
  version = "0.4.2";
  src = fetchFromGitHub {
    owner = "fannheyward";
    repo = pname;
    rev = "d247884";
    sha256 = "1p0j9xm8a7w1gaq24x3kk2jw5q4y1waz6l66709cxjisi9c69p7y";
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
    (fetchpatch {
      # ssr (Structural Search Replace)
      url = "https://github.com/fannheyward/coc-rust-analyzer/commit/9a5664e52576fe9a17824dfd5373375136c48725.patch";
      sha256 = "13lphfg0y4cgkj11r4z80y187ljjwzyz1vns4dsw36i8ddrfk32y";
    })
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
