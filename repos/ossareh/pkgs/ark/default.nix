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

    useFetchCargoVendor = true;
    cargoHash = "sha256-QkitKjfLW/aVeuff67SmLnxg7JAdMEaeW8YuEwQfrhw=";

    meta = {
      broken = true;
      description = "Ark is an R kernel for Jupyter applications";
      homepage = "https://github.com/posit-dev/ark";
      license = lib.licenses.mit;
      maintainers = ["github.com/ossareh"];
    };
  }
