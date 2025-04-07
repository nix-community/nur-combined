{
  pkgs,
  lib,
  fetchFromGitHub,
  rustPlatform,
}: let
  pname = "ark";
  version = "0.1.177";
  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = pname;
    rev = version;
    hash = "sha256-d5xaa4OQjGOkPHoKumjS1qR6TYF2i3EP055tHEUI1lM=";
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    useNextest = true;

    nativeBuildInputs = [
      (
        pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            Matrix
            R6
            haven
            rqdatatable
            rstudioapi
            tibble
          ];
        }
      )
    ];

    useFetchCargoVendor = true;
    cargoHash = "sha256-84dwX/poL+pRTijgyVw3r7N3eRwBJ6GonVsBzOFbLz8=";

    meta = {
      broken = true;
      description = "Ark is an R kernel for Jupyter applications";
      homepage = "https://github.com/posit-dev/ark";
      license = lib.licenses.mit;
      maintainers = ["github.com/ossareh"];
    };
  }
