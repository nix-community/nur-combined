{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "hyprzoom";
  version = "0.1.0";

  # https://github.com/nouritsu/hyprzoom
  src = fetchFromGitHub {
    owner = "nouritsu";
    repo = "hyprzoom";
    rev = "80b7b8f475cd782942cae52b158f057c0f90b67a";
    hash = "sha256-DYkNm/pVj4ha1XaZw2cTX4fWS/L4+aPVQotFofdHOsQ=";
  };

  cargoHash = "sha256-DFfLLML0DUhLHRiwCy7CG13EKlvAG0EIVi4yfJAwx/0=";

  passthru.updateScript = "./update.sh";

  meta = with lib; {
    description = "Simple yet feature rich zoom utility for Hyprland";
    homepage = "https://github.com/nouritsu/hyprzoom";
    license = licenses.mit;
    maintainers = with maintainers; [ lonerOrz ];
    mainProgram = "thyprzoom";
  };
})
