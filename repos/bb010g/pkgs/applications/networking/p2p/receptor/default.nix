{ stdenv, pkgs, buildEnv, buildPackages, fetchFromGitHub
, nodejs-10_x }:

let
  srcMeta = {
    owner = "ddevault";
    repo = "receptor";
    rev = "9c252c7251f76785723fd46b36d9af91f808d41d";
  };

  src = fetchFromGitHub {
    inherit (srcMeta) owner repo rev;
    fetchSubmodules = true;
    sha256 = "10lfb0lh6f3dj90404ihcqzx3x4npx0hk3sd1vqbg348ih98ca1b";
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
  version = "2019-06-15";

  inherit src;

  buildInputs = [ nodejs-10_x ];

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

  meta = let inherit (stdenv) lib; in {
    description = "Web frontend for the synapse bittorrent client";
    downloadPage = https://github.com/ddevault/receptor;
    license = lib.licenses.bsd3;
    maintainers = let m = lib.maintainers; in [ m.bb010g ];
  };
}
