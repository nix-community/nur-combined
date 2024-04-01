{ lib
, stdenv
, pkgs
, system ? builtins.currentSystem
, ...
}:

let
  nodejs = pkgs.nodejs_18;
  nodePackages = import ./node2nix
    {
      inherit pkgs system nodejs;
    };
  nodeDependencies = nodePackages.nodeDependencies;
in
stdenv.mkDerivation
{
  pname = "s3-browser-cli";
  version = (builtins.fromJSON (builtins.readFile ./../package.json)).version;
  src = ./..;

  buildInputs = with pkgs;
    [ nodejs makeWrapper ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
  '';

  installPhase = ''
    export PATH="${nodeDependencies}/bin:$PATH"
    mkdir -p $out/bin
   
    cp index.js package.json $out/
    ln -s ${nodeDependencies}/lib/node_modules $out/node_modules

    # create cli binary
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/s3select --add-flags "$out/index.js" --inherit-argv0
  '';

  meta = with lib;
    {
      homepage = "https://github.com/nesto-software/s3-browser-cli";
      description = "A cli tool to select s3 keys interactively";

      license = licenses.mit;
      platforms = platforms.all;
      mainProgram = "s3select";
    };
}
