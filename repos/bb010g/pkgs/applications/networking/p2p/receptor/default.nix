{ stdenv, pkgs, buildEnv, buildPackages, fetchFromGitHub
, nodejs-8_x }:

let
  srcMeta = {
    owner = "ddevault";
    repo = "receptor";
    rev = "1dc07756256c49599e58b4e917312ca0569e6b06";
  };

  src = fetchFromGitHub {
    inherit (srcMeta) owner repo rev;
    fetchSubmodules = true;
    sha256 = "1d1zdm1pkbqnszcw6y2jnhynd09l97a0c7ad9gz9wzw16sd730zg";
  };

  pNodeUrl = let inherit (srcMeta) owner repo rev; in
    "git+https://github.com/${owner}/${repo}#${rev}";
  pNodeName = "receptor-${pNodeUrl}";

  nodeDevPackages = let o = import ./node-dev.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
  }; in o // {
    ${pNodeName} = o.${pNodeName}.override { inherit src; };
  };

  nodeDevPkg = nodeDevPackages.${pNodeName};
in stdenv.mkDerivation rec {
  pname = "receptor-unstable";
  version = "2019-03-15";

  inherit src;

  buildInputs = [ nodejs-8_x ];

  postPatch = ''
    patchShebangs .
  '';

  buildPhase = ''
    ln -s ${nodeDevPkg}/lib/node_modules/receptor/node_modules node_modules
    npm --offline --production run build:production
  '';

  installPhase = ''
    mkdir -p "$out/webapps/receptor/"
    cp -t "$out/webapps/receptor/" -Rv dist index.html
  '';

  meta = with stdenv.lib; {
    description = "Web frontend for the synapse bittorrent client";
    downloadPage = https://github.com/ddevault/receptor;
    license = with licenses; bsd3;
    maintainers = with maintainers; [ bb010g ];
  };
}
