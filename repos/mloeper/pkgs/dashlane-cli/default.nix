{ lib
, stdenv
, pkgs
, fetchFromGitHub
, system ? builtins.currentSystem
, withMasterPasswordStoreDisabled ? false
, ...
}:

# TODO: add generate script for node2nix like e.g.: https://github.com/NixOS/nixpkgs/blob/f8d3c2dabdab26f53fe95079d7725da777019ff2/pkgs/development/web/netlify-cli/generate.sh
let
  nodejs = pkgs.nodejs_18;
  nodePackages = import ./node2nix {
    inherit pkgs system nodejs;
  };
  nodeDependencies = nodePackages.nodeDependencies;
in
stdenv.mkDerivation
{
  pname = "dashlane-cli";
  version = "1.13.0";
  src = fetchFromGitHub {
    owner = "Dashlane";
    repo = "dashlane-cli";
    rev = "28fd4ec19c79738aa75acb8672cdd1691f8a7465";
    hash = "sha256-HiuRzcEI+6oP9oaOTxgUK41a1ajZBvAnE/bVCnzIDk0=";
  };

  buildInputs = with pkgs; [ nodejs yarn makeWrapper ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
    
    tsc
    cp -r dist $out/
    cp -r ${nodeDependencies}/lib/node_modules $out/node_modules

    # create binary using wrapper script
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/dcli --add-flags "$out/index.js" --inherit-argv0 ${if withMasterPasswordStoreDisabled then "--run \"${pkgs.nodejs}/bin/node $out/index.js configure save-master-password false\"" else ""}
  '';

  meta = with lib; {
    homepage = "https://github.com/Dashlane/dashlane-cli";
    description = "The official Dashlane CLI";

    # for SSO, see: https://github.com/Dashlane/dashlane-cli/blob/28fd4ec19c79738aa75acb8672cdd1691f8a7465/src/modules/auth/sso/index.ts#L4
    longDescription = ''
      Dashlane CLI is a command line interface for Dashlane. 
      It allows you to interact with your Dashlane account, and to manage your passwords and personal data.

      Note: To use the Dashlane SSO feature, you must install the chromium browser and set PLAYWRIGHT_BROWSERS_PATH properly. 
    '';
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "dcli";
  };
}
