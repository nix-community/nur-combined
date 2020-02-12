{ stdenv, fetchFromGitHub, rustPlatform, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "maple";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "liuchengxu";
    repo = "vim-clap";
    rev = "v${version}";
    sha256 = "1klbl6j8618bdhsvpplwq2igakgcgzgc4j1428s428kxr7g4l7pb";
  };

  cargoSha256 = "1crwd8444zaa0yb8jz01nij4xzc5s0qh8h0v6l6x3lbwxg7idbay";

  nativeBuildInputs = [ pkgconfig ];
  doCheck = false;

  meta = with stdenv.lib; {
    description =
      "Modern performant generic finder and dispatcher for Vim and NeoVim";
    homepage = "https://github.com/liuchengxu/vim-clap";
    license = licenses.mit;
  };
}
