{ lib, fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "lohr";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "alarsyo";
    repo = "lohr";
    rev = "v${version}";
    hash = "sha256-2pN/Me5fCdE++TzBUswPXzjuUIIB7Uck+Scp361JgE4=";
  };

  cargoHash = "sha256-YHg4b6rKcnVJSDoWh9/o+p40NBog65Gd2/UwIDXiUe0=";

  meta = with lib; {
    description = "Git mirroring daemon";
    homepage = "https://github.com/alarsyo/lohr";
    license = with licenses; [ mit asl20 ];
    platforms = platforms.unix;
    maintainers = with maintainers; [ ambroisie ];
  };
}
