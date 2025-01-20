{
  pkgs,
  lib,
  fetchFromGitHub,
  rustPlatform,
}: let
  pname = "ark";
  version = "0.1.159";
  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = pname;
    rev = version;
    hash = "sha256-dRF1PheW66ZVj+8MFzEk9RnewfWgJHIJVmfa0fpr1Ts=";
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    nativeBuildInputs = [
      (
        pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            rqdatatable
            rstudioapi
            tibble
          ];
        }
      )
    ];

    # Debug output for Cargo.lock
    # cargoLock = let
    #   lockFile = "${src}/Cargo.lock";
    # in {
    #   lockFile = lockFile;
    #   outputHashes = {
    #     "dap-0.4.1-alpha1" = "sha256-nUsTazH1riI0nglWroDKDWoHEEtNEtpwn6jCH2N7Ass=";
    #     "tree-sitter-r-1.1.0" = "sha256-gF1sarYoI+6pjww1++eEu0sUDlH2cOddP1k/SjFozFg=";
    #   };
    # };

    meta = {
      description = "Ark is an R kernel for Jupyter applications";
      homepage = "https://github.com/posit-dev/ark";
      license = lib.licenses.mit;
      maintainers = ["github.com/ossareh"];
    };
  }
