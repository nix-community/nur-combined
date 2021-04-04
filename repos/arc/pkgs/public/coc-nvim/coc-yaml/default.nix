{ fetchFromGitHub, yarn2nix, yarn, vimUtils, yaml-language-server, nodePackages }: let
  pname = "coc-yaml";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "neoclide";
    repo = pname;
    rev = version;
    sha256 = "1xjwpkzwb47ahml3rc1cngjw069yi08sw2wvp8sdka0fcy6sbs59";
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

  preInstall = ''
    install -d node_modules/yaml-language-server/out/server/src
    ln -s ${yaml-language-server}/bin/yaml-language-server node_modules/yaml-language-server/out/server/src/server.js
  '';

  meta.broken = !(builtins.tryEval yarn2nix).success || yarn.stdenv.isDarwin;
}
