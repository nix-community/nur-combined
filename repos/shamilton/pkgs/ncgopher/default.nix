{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, ncurses6
, openssl
, sqlite
}:

rustPlatform.buildRustPackage rec {
  pname = "ncgopher";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "jansc";
    repo = "ncgopher";
    rev = "v${version}";
    sha256 = "1mv89sanmr49b9za95jl5slpq960b246j2054r8xfafzqmbp44af";
  };

  cargoSha256 = "11gn31jfdbjcp3mcg1c3iyxk3s0dkmiwa64q01zkvd9yw6n9yjv5";
  verifyCargoDeps = true;
  
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    (lib.getDev ncurses6)
    openssl
    sqlite
  ];

  meta = with lib; {
    description = "A gopher and gemini client for the modern internet";
    homepage = "https://github.com/jansc/ncgopher";
    license = licenses.bsd2;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
