{ stdenv, rustPlatform, buildPackages, fetchFromGitHub
, libX11, libXrandr
}:

rustPlatform.buildRustPackage rec {
  pname = "shotgun";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "shotgun";
    rev = "v${version}";
    sha256 = "1jljwcpzsqixhacv8zhflmf67a6z6sffbwcf0px3gpcvpkvfvw19";
  };

  cargoSha256 = "1zvmzmdwq9ddngfdk6psng1z1mvsdn3vqkzaavs0d90fj7lxlnvx";

  nativeBuildInputs = [ buildPackages.pkgconfig ];
  buildInputs = [ libX11 libXrandr ];

  meta = with stdenv.lib; {
    description = "A minimal screenshot utility for X11";
    homepage = https://github.com/neXromancers/shotgun;
    license = with licenses; mpl20;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}

