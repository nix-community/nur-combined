{
  pkgs,
  lib,
  fetchFromGitHub,
  rustPlatform,
}: let
  pname = "ark";
  version = "0.1.170";
  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = pname;
    rev = version;
    hash = "sha256-qbdqWlpMp39Ft2A4Gyy3GCH3ohPxyKpEdky2DgvbEUI=";
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
    cargoHash = "sha256-U494SEiN4dH/dYb9afQA/OUXMPctqgYQgS3COu9eDMs=";

    meta = {
      broken = true;
      description = "Ark is an R kernel for Jupyter applications";
      homepage = "https://github.com/posit-dev/ark";
      license = lib.licenses.mit;
      maintainers = ["github.com/ossareh"];
    };
  }
