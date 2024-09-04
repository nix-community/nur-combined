{ lib, fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "lohr";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "alarsyo";
    repo = "lohr";
    rev = "v${version}";
    hash = "sha256-dunQgtap+XCK5LoSyOqIY/6p6HizBeiyPWNuCffwjDU=";
  };

  cargoHash = "sha256-EUhyrhPe+mUgMmm4o+bxRIiSNReJRfw+/O1fPr8r7lo=";

  meta = with lib; {
    description = "Git mirroring daemon";
    homepage = "https://github.com/alarsyo/lohr";
    license = with licenses; [ mit asl20 ];
    mainProgram = "lohr";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.unix;
  };
}
