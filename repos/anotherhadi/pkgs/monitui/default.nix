{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "monitui";
  version = "0.2.3-unstable-2026-03-14";

  src = fetchFromGitHub {
    owner = "nathaniel-fargo";
    repo = "monitui";
    rev = "3fd537e86421fcf2d1731a0f0869eb46a5fd1d5e";
    hash = "sha256-2DMN1Ss8yX4ht2cjH/jaq8pqyMc20yroneFKLSU2pig=";
  };

  cargoHash = "sha256-YMtw8Hsqzi0rVdwVzxfETFlNDS4DCaLoHzT+s+9L2+g=";

  meta = with lib; {
    description = "Delightfully minimal TUI for wrangling Hyprland monitors";
    homepage = "https://github.com/nathaniel-fargo/monitui";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
    mainProgram = "monitui";
  };
}
