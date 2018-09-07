{ supportedSystems ? [ "x86_64-linux"] }:

let

  inherit (import ./lib/release) mkJob fetchNur;

  myPkgs = pkgs: { mapTestOn, linux, ... }: mapTestOn {
    nur.repos = {
      mic92.cntr = linux;
      ma27.gianas-return = linux;
    };

    termite = linux;
    sudo = linux;
    hydra = linux;
  };

  overlays = builtins.attrValues ((fetchNur (import <nixpkgs> {})).repos.ma27.overlays);

in

  {

    nur-personal-stable = mkJob {
      channel = "18.09";
      func = myPkgs;
      inherit overlays supportedSystems;
    };

    nur-personal-unstable = mkJob {
      channel = "unstable";
      func = myPkgs;
      inherit overlays supportedSystems;
    };

  }
