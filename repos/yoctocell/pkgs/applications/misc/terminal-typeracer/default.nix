{ stdenv
, fetchFromGitLab
, sources
, rustPlatform
, pkg-config
, openssl
, sqlite
}:

rustPlatform.buildRustPackage rec {
  pname = "terminal-typeracer";
  version = builtins.substring 7 0 src.rev;

  src = fetchFromGitLab {
    owner = "ttyperacer";
    repo = "terminal-typeracer";
    rev = "0249e6279e85c9040e800422539bf6d166c3664f";
    sha256 = "12406l6jflhn7wy8i5sv848389fh7db3gnc6di412f57sxj2p16s";
  };

  cargoSha256 = "13xwkpbp632pv15xjhfb7q8sfbj561q20wsm842bv7w39g8hj1w9";

  buildInputs = [ openssl sqlite ];
  nativeBuildInputs = [ pkg-config ];

  meta = with stdenv.lib; {
    description = "An open source terminal based version of Typeracer written in rust";
    homepage = "https://gitlab.com/ttyperacer/terminal-typeracer";
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.x86_64;
  };
}
