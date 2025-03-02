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

  useFetchCargoVendor = true;
  cargoHash = "sha256-R3/N/43+bGx6acE/rhBcrk6kS5zQu8NJ1sVvKJJkK9w=";

  meta = with lib; {
    description = "Git mirroring daemon";
    homepage = "https://github.com/alarsyo/lohr";
    license = with licenses; [ mit asl20 ];
    mainProgram = "lohr";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.unix;
  };
}
