{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "dispath";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mpoquet";
    repo = "dispath";
    rev = "v${version}";
    sha256 = "sha256-bO1eoH/gTK0gNuj36OhvUUwsmJYAOblz4BGt4PCe/g4=";
  };

  buildInputs = [];
  nativeBuildInputs = [];

  cargoHash = "sha256-QbY6PicJObGxHVMvU9QPt01ykHN8soEhZvJAfdXbTXA=";

  meta = with lib; {
    homepage = https://github.com/mpoquet/dispath;
    description = "Display PATH-like environment variables, one entry per line.";
    license = licenses.gpl3;
    broken = false;
  };
}
