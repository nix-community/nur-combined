{ stdenv, fetchFromGitHub, rustPlatform, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "maple";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "liuchengxu";
    repo = "vim-clap";
    rev = "v${version}";
    sha256 = "18zf15yg6fvcrpvsl8ff2gihyi9pnx0pr91k5m5y1888s9gc0lf4";
  };

  cargoSha256 = "0wrnd8rqd76ybqaypa0apjfs2621xym1kl2idzjw1wvgcssy3hii";

  nativeBuildInputs = [ pkgconfig ];
  doCheck = false;

  meta = with stdenv.lib; {
    description =
      "Modern performant generic finder and dispatcher for Vim and NeoVim";
    homepage = "https://github.com/liuchengxu/vim-clap";
    license = licenses.mit;
  };
}
