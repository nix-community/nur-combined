{ lib

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "lddtree";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "messense";
    repo = "lddtree-rs";
    rev = "v${version}";
    hash = "sha256-VxMYHK0pTp+hSM6PIohn35sLWJUrSJI9xmTbw1wLAvc=";
  };

  cargoHash = "sha256-hw6Su5qL+nveX6MnoKit1gTGxqN5JLzXbt1Xxebr5IQ=";

  meta = with lib; {
    description = "Read the ELF dependency tree";
    homepage = "https://github.com/messense/lddtree-rs";
    license = licenses.mit;
    mainProgram = "lddtree";
  };
}
