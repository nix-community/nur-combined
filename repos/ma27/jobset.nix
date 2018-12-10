{ nixpkgs ? <nixpkgs>, supportedSystems ? [ "x86_64-linux" ] }:

let

  inherit (import ./. { pkgs = import nixpkgs {}; }) mkJob mkTests overlays;

  ### TESTS
  libraryTests = callPackage: mkTests [
    (callPackage ./tests/test-checkout-nixpkgs.nix { })
    (callPackage ./tests/test-mkjob.nix { })
    (callPackage ./tests/test-containers.nix { })
  ];

  vmTests =  {
    hydra = (import ./modules/tests/hydra.nix { }).test;
  };

  ### HYDRA CONFIG
  jobset = { mapTestOn, linux, ... }: mapTestOn {
    gianas-return = linux;
    termite = linux;
    sudo = linux;
    hydra = linux;
    library-tests = linux;
    php = linux;
    vmTests.hydra = linux;
  };

  newOverlays = (builtins.attrValues overlays) ++ [
    (_: super: import ./. { pkgs = super; })
    (_: super: { library-tests = libraryTests super.callPackage; })
    (_: super: { inherit vmTests; })
  ];

in

  {

    nur-personal-stable = mkJob {
      channel = "18.09";
      overlays = newOverlays;
      inherit supportedSystems jobset;
    };

    nur-personal-unstable = mkJob {
      channel = "unstable";
      overlays = newOverlays;
      inherit supportedSystems jobset;
    };

    nur-personal-laptop = mkJob {
      channel = "ma27-laptop";
      trackBranches = true;
      upstream = "Ma27";
      inherit supportedSystems jobset;
      overlays = newOverlays;
    };

    nur-personal-infra = mkJob {
      channel = "ma27-infra";
      trackBranches = true;
      upstream = "Ma27";
      inherit supportedSystems jobset;
      overlays = newOverlays;
    };

  }
