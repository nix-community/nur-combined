{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "hyprzoom";
  version = "0.1.0";

  # https://github.com/nouritsu/hyprzoom.git
  src = fetchFromGitHub {
    owner = "nouritsu";
    repo = "hyprzoom";
    rev = "main";
    hash = "sha256-DYkNm/pVj4ha1XaZw2cTX4fWS/L4+aPVQotFofdHOsQ=";
  };

  cargoHash = "sha256-DFfLLML0DUhLHRiwCy7CG13EKlvAG0EIVi4yfJAwx/0=";

  passthru.autoUpdate = false;

  meta = with lib; {
    description = "Simple yet feature rich zoom utility for Hyprland";
    homepage = "https://github.com/nouritsu/hyprzoom";
    license = licenses.mit;
    maintainers = with maintainers; [ lonerOrz ];
    mainProgram = "thyprzoom";
  };
})
