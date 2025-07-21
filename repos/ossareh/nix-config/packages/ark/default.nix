{
  lib,
  fetchFromGitHub,
  rustPlatform,
}: let
  pname = "ark";
  version = "0.1.197";
  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = pname;
    rev = version;
    hash = "sha256-sLHJIdwubjpOrq9N/IkuVu9AqKnl+tTCSJs6zQZhZf8=";
  };
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;
    src = src;

    useNextest = true;

    useFetchCargoVendor = true;
    cargoHash = "sha256-Fv/9jOu4+UyrK9Me2iCvRkcT4vbzVR6E9K+BbrVb+gM=";

    meta = {
      broken = true;
      description = "Ark is an R kernel for Jupyter applications";
      homepage = "https://github.com/posit-dev/ark";
      license = lib.licenses.mit;
      maintainers = ["github.com/ossareh"];
    };
  }
