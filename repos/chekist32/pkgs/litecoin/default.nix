{ pkgs }:

let
  litecoinSharedConfig = {
    stdenv = pkgs.gcc14Stdenv;
    boost = pkgs.boost183;
    miniupnpc = pkgs.miniupnpc.overrideAttrs (oldAttrs: rec {
      version = "2.2.2";
      src = pkgs.fetchFromGitHub {
        owner = "miniupnp";
        repo = "miniupnp";
        tag = "miniupnpc_${pkgs.lib.replaceStrings [ "." ] [ "_" ] version}";
        hash = "sha256-4v62pQUedlPFXsCZmC2aMGDKfDVFBx5HK+CWLTi8TOg=";
      };
      patches = [ ];
      postInstall = "";
      doInstallCheck = false;
    });
  };

  litecoinQt5Config = {
    inherit (pkgs.libsForQt5.qt5) qtbase qttools wrapQtAppsHook;
  };
in
{
  litecoin = pkgs.callPackage ./package.nix (
    litecoinSharedConfig // litecoinQt5Config // { withGui = true; }
  );

  litecoin-cli = pkgs.callPackage ./package.nix (litecoinSharedConfig // { withGui = false; });
}
