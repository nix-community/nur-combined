{ lib, rustPlatform, fetchFromGitHub, git }:

rustPlatform.buildRustPackage rec {
  pname = "lsd";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "lsd-rs";
    repo = "lsd";
    rev = "v${version}";
    sha256 = "sha256-BDwptBRGy2IGc3FrgFZ1rt/e1bpKs1Y0C3H4JfqRqHc=";
  };

  cargoHash = "sha256-TcC8ZY8Xv0076bLrprXGPh5nyGnR2NRnGeuTSEK4+Gg=";

  ## for checkPhase
  nativeBuildInputs = [ git ];

  meta = with lib; {
    description = "The next gen ls command";
    homepage = https://github.com/lsd-rs/lsd;
    license = licenses.asl20;
    maintainers = [ maintainers.bendlas ];
    platforms = platforms.all;
  };
}
