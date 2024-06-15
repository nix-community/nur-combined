{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "rgssad";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "luxrck";
    repo = "rgssad";
    rev = "v${version}";
    hash = "sha256-dQAkA4/lOotTdKwwb0Cwh7eJurT/7q+ogBehwrvaIDg=";
  };

  cargoHash = "sha256-Cse8KhIIc6Q6/krnkT3vypjNVA8ho8JUcV9GxhgSC60=";

  meta = with lib; {
    description = "Extract rgssad/rgss2a/rgss3a files";
    homepage = "https://github.com/luxrck/rgssad";
    license = licenses.mit;
    mainProgram = "rgssad";
  };
}
