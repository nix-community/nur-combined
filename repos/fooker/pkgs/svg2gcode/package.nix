{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "svg2gcode";
  version = "0.0.18";

  src = fetchFromGitHub {
    owner = "sameer";
    repo = "svg2gcode";
    rev = "cli-v${finalAttrs.version}";
    hash = "sha256-G60wGegUiaaVNnNmwWMJnu5nE8FStJwiD8LoyUKOiDM=";
  };

  cargoHash = "sha256-2V6x19obh6P5HqDHqnlGW2gNflwNEPfREEZUNLZCtro=";

  cargoBuildFlags = [ "-p" "svg2gcode-cli" ];
  cargoTestFlags = [ "-p" "svg2gcode-cli" ];

  meta = with lib; {
    description = "Convert vector graphics to G-Code for pen plotters, laser engravers, and CNC machines";
    homepage = "https://github.com/sameer/svg2gcode";
    license = licenses.mit;
    mainProgram = "svg2gcode";
  };
})
