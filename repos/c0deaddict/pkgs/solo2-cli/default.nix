{ lib, fetchFromGitHub, rustPlatform, pkg-config, pcsclite, libudev }:

rustPlatform.buildRustPackage rec {
  pname = "solo2-cli";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "solokeys";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-3GIK0boxGD4Xa5OskP1535zCQyhMQ/oXbgThRivJzww=";
  };

  cargoSha256 = "sha256-MYxVegXUVeZ4AzDz+Si5TtTjUDEPTO0Nh008rgLtsLw=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcsclite libudev ];

  meta = with lib; {
    description = "solo2 library and CLI";
    homepage = "https://github.com/solokeys/solo2-cli";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
