{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl_1_1 }:

rustPlatform.buildRustPackage rec {
  pname = "silver";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "reujab";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CFQMIyG4+cMp2Do4ygbbl62GMw9gvpV22TcxtgQ9LN0=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl_1_1 ];

  cargoHash = "sha256-bWe5p+z5JUia0dIvFzCcH5xReu3nCrMwJtE+YfovuI4=";

  meta = with lib; {
    description = "A cross-shell customizable powerline-like prompt with icons";
    homepage = https://github.com/reujab/silver;
    license = licenses.unlicense;
    platforms = platforms.linux;
  };
}
