{ nixpkgs ? <nixpkgs>, supportedSystems ? [ "x86_64-linux"] }:

let

  inherit (import ./. { pkgs = import nixpkgs {}; }) mkJob mkTests;

  ### TESTS
  libraryTests = callPackage: mkTests [
    (callPackage ./tests/test-checkout-nixpkgs.nix { })
    (callPackage ./tests/test-mkjob.nix { })
  ];

  jobset = { mapTestOn, linux, ... }: mapTestOn {
    gianas-return = linux;
    termite = linux;
    sudo = linux;
    hydra = linux;
    libraryTests = linux;
  };

  overlays = [
    (_: super: import ./. { pkgs = super; })
    (_: super: { libraryTests = libraryTests super.callPackage; })
  ];

in

  {

    nur-personal-stable = mkJob {
      channel = "18.09";
      inherit overlays supportedSystems jobset;
    };

    nur-personal-unstable = mkJob {
      channel = "unstable";
      inherit overlays supportedSystems jobset;
    };

    nur-personal-laptop = mkJob {
      channel = "ma27-laptop";
      trackBranches = true;
      upstream = "Ma27";
      inherit overlays supportedSystems jobset;
    };

    nur-personal-infra = mkJob {
      channel = "ma27-infra";
      trackBranches = true;
      upstream = "Ma27";
      inherit overlays supportedSystems jobset;
    };

  }
