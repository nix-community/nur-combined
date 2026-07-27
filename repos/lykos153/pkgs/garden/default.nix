{ lib
, fetchFromGitLab
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "garden";
  version = "1.7.0";
  src = fetchFromGitLab {
    owner = "garden-rs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KkvG8/WSr1HHCIoItY0hgriEilY6TzHgcs6L2GaA/lk=";
  };
  cargoHash = "sha256-f8UHZ/rNWio8TJj99VsO0JztxOrAgOH32zHCogtX4N8=";

  doCheck = false;

  meta = with lib; {
    description = "Garden grows and cultivates collections of Git trees.";
    homepage = "https://gitlab.com/garden-rs/garden";
    license = licenses.mit;
  };
}
