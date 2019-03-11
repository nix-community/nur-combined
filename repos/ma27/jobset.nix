{ nixpkgs ? <nixpkgs>, supportedSystems ? [ "x86_64-linux" ] }:

let

  inherit (import ./. { pkgs = import nixpkgs {}; }) mkJobset;

in

mkJobset {
  jobsetPrefix = "nur-personal";

  jobset = { mapTestOn, linux, ... }: mapTestOn {
    gianas-return = linux;
    termite = linux;
    sudo = linux;
    hydra = linux;
    nur-personal-library-tests = linux;
    php = linux;
    nur-personal-vm-tests.hydra = linux;
  };

  sources = [
    { inherit supportedSystems;
      channel = "ma27-laptop-19.03";
      trackBranches = true;
      upstream = "Ma27";
    }
    { inherit supportedSystems;
      channel = "ma27-infra";
      trackBranches = true;
      upstream = "Ma27";
    }
  ];

  vmTests = {
    hydra = (import ./modules/tests/hydra.nix { }).test;
  };

  libraryTests = [
    ./tests/test-checkout-nixpkgs.nix
    ./tests/test-containers.nix
    ./tests/test-mkjob.nix
  ];
}
