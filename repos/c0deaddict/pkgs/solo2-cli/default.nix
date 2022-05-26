{ lib, fetchFromGitHub, rustPlatform, pkg-config, pcsclite, udev }:

rustPlatform.buildRustPackage rec {
  pname = "solo2-cli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "solokeys";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-CRufj4SAkM0Qdffq45dp41TUqnnWep4zCB0XrEjdoG8=";
  };

  cargoSha256 = "sha256-Q6/Vi5TB0H3OQ4np/DYIpTOsTPTSDjHonFI24LJ5gWE=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcsclite udev ];

  meta = with lib; {
    description = "solo2 library and CLI";
    homepage = "https://github.com/solokeys/solo2-cli";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
