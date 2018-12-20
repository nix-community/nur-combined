{ stdenv, fetchFromGitHub, rustPlatform
, libX11, libXrandr
, pkgconfig }:

rustPlatform.buildRustPackage rec {
  name = "shotgun-${version}";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "shotgun";
    rev = "v${version}";
    sha256 = "0ycj6y8ym2y6y91s3qi9v8w3p8nz795cd0q79lrfrjxz7s2jvdlv";
  };

  cargoSha256 = "0f8gwfg7p38zwkpi6k6dn0gq5f4f2khmw7jrj8as6ihdhqwb7q0c";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libX11 libXrandr ];

  meta = with stdenv.lib; {
    description = "A minimal screenshot utility for X11";
    homepage = https://github.com/neXromancers/shotgun;
    license = with licenses; [ mpl20 ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}

