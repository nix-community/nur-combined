{ lib, fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "lohr";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "alarsyo";
    repo = "lohr";
    rev = "v${version}";
    hash = "sha256-p6E/r+OxFTpxDpOKSlacOxvRLfHSKg1mHNAfTytfqDY=";
  };

  cargoHash = "sha256-hext0S0o9D9pN9epzXtD5dwAYMPCLpBBOBT4FX0mTMk=";

  meta = with lib; {
    description = "Git mirroring daemon";
    homepage = "https://github.com/alarsyo/lohr";
    license = with licenses; [ mit asl20 ];
    mainProgram = "lohr";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.unix;
  };
}
