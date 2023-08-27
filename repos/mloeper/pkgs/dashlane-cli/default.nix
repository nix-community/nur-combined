{ lib, stdenv, pkgs, fetchFromGitHub, system ? builtins.currentSystem, ... }:

# TODO: add generate script for node2nix like e.g.: https://github.com/NixOS/nixpkgs/blob/f8d3c2dabdab26f53fe95079d7725da777019ff2/pkgs/development/web/netlify-cli/generate.sh
let
  nodePackages = import ./node2nix {
    inherit pkgs system;
    nodejs = pkgs.nodejs_18;
  };
  nodeDependencies = nodePackages.nodeDependencies;
in
nodeDependencies

# stdenv.mkDerivation {
#   pname = "dashlane-cli";
#   version = "1.13.0";
#   src = ./.;

#   buildInputs = with pkgs; [ nodejs_18 yarn ];

#   buildPhase = ''
#     ln -s ${nodeDependencies}/lib/node_modules ./node_modules
#     export PATH="${nodeDependencies}/bin:$PATH"

#     #yarn run --offline build
#     #cp -r dist $out/
#   '';

#   meta = with lib; {
#     homepage = "https://github.com/Dashlane/dashlane-cli";
#     description = "A Dashlane CLI";

#     # for SSO, see: https://github.com/Dashlane/dashlane-cli/blob/28fd4ec19c79738aa75acb8672cdd1691f8a7465/src/modules/auth/sso/index.ts#L4
#     longDescription = ''
#       Dashlane CLI is a command line interface for Dashlane. 
#       It allows you to interact with your Dashlane account, and to manage your passwords and personal data.

#       Note: To use the Dashlane SSO feature, you must install the chromium browser and set PLAYWRIGHT_BROWSERS_PATH properly. 
#     '';
#     license = licenses.asl20;
#     platforms = [ "x86_64-linux" ];
#     mainProgram = "dcli";
#   };
# }
