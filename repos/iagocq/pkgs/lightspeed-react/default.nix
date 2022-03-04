{ stdenv, pkgs, fetchgit, nodejs, websocketURL ? "ws://stream.gud.software:8080/websocket" }:

let
  nodePackages = import ./n2n-default.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
  };
  lightspeed-react = nodePackages."lightspeed-react-git://github.com/GRVYDEV/Lightspeed-react.git";
in

stdenv.mkDerivation {
  pname = "lightspeed-react";
  version = "20210221-08c2894b5a3059d24c664aefe6256c88f0f15038";

  src = fetchgit {
    url = "git://github.com/GRVYDEV/Lightspeed-react.git";
    rev = "08c2894b5a3059d24c664aefe6256c88f0f15038";
    sha256 = "f9fbebe317a569e7f3551c54a34b473a6ce2ffb2942d7bbf6131be88a2a2a5ad";
  };

  buildInputs = [ nodejs ];

  patchPhase = ''
    find . -name .DS_Store -delete
    substituteInPlace public/config.json \
      --replace 'ws://stream.gud.software:8080/websocket' '${websocketURL}'
  '';

  buildPhase = ''
    ln -s ${lightspeed-react}/lib/node_modules/lightspeed-react/node_modules ./node_modules
    export PATH="${lightspeed-react}/lib/node_modules/lightspeed-react/node_modules/.bin:$PATH"

    react-scripts build
  '';

  installPhase = ''
    cp -R build/ $out
  '';
}
