{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "dtsfmt";
  version = "0.6.0-3dd547f";

  src = fetchFromGitHub {
    owner = "mskelton";
    repo = "dtsfmt";
    rev = "3dd547fe8c55c8f5b7c1e5454f4321c6fd9365d7";
    hash = "sha256-ArGj5orWE2+4E/CJU5WOBUUlDvH4z0gAG4DM3htFSDY=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-VCI4qHOpN9xRTHuoE7/+Ybbg0eAmeDD4lNoUQZxJiAE=";

  meta = {
    description = "Auto formatter for device tree files";
    longDescription = ''
      Auto formatter for device tree files.
    '';
    homepage = "https://github.com/mskelton/dtsfmt";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "dtsfmt";
  };
}
