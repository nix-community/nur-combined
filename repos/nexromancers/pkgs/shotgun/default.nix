{ stdenv, rustPlatform, fetchFromGitHub
, libX11, libXrandr
, pkgconfig
}:

rustPlatform.buildRustPackage rec {
  name = "shotgun-${version}";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "shotgun";
    rev = "v${version}";
    sha256 = "1jljwcpzsqixhacv8zhflmf67a6z6sffbwcf0px3gpcvpkvfvw19";
  };

  cargoSha256 = "19l4v530s6v8qk1h83k6gs70gi0rzls1ahj2z87bl780m329q0bz";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libX11 libXrandr ];

  meta = with stdenv.lib; {
    description = "A minimal screenshot utility for X11";
    homepage = https://github.com/neXromancers/shotgun;
    license = with licenses; mpl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}

