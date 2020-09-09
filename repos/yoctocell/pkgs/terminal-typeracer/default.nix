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
  version = "0249e6279e85c9040e800422539bf6d166c3664f";

  src = fetchFromGitLab {
    owner = "ttyperacer";
    repo = "terminal-typeracer";
    rev = "0249e6279e85c9040e800422539bf6d166c3664f";
    sha256 = "12406l6jflhn7wy8i5sv848389fh7db3gnc6di412f57sxj2p16s";
  };

  cargoSha256 = "1i2i5hlqh60sdsklrjybkly2dhm0fd79h8p3argyl0r9yfv00qvi";

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
