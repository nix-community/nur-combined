{
  pkgs,
  lib,
  fetchFromGitHub,
  rustPlatform,
}: let
  pname = "ark";
  version = "0.1.185";
  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = pname;
    rev = version;
    hash = "sha256-4fqz0DpMJlfhehyH7XkVrIipPbJm9raVxqAL0zQq++w=";
  };
  rPkg = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      R6
      haven
      rqdatatable
      rstudioapi
      tibble
    ];
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    useNextest = true;

    nativeBuildInputs = [rPkg];

    useFetchCargoVendor = true;
    cargoHash = "sha256-URVZPJelZf+ikCAcGmrCq1KfV7xDjW5EZbaaZpWYecA=";

    meta = {
      broken = true;
      description = "Ark is an R kernel for Jupyter applications";
      homepage = "https://github.com/posit-dev/ark";
      license = lib.licenses.mit;
      maintainers = ["github.com/ossareh"];
    };
  }
