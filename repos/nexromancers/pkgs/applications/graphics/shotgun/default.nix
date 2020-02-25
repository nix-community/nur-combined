{ stdenv, rustPlatform, buildPackages, fetchFromGitHub
, libX11, libXrandr
}:

rustPlatform.buildRustPackage rec {
  pname = "shotgun";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "shotgun";
    rev = "v${version}";
    sha256 = "0fpc09yvxjcvjkai7afyig4gyc7inaqxxrwzs17mh8wdgzawb6dl";
  };

  cargoSha256 = "0sbhij8qh9n05nzhp47dm46hbc59awar515f9nhd3wvahwz53zam";

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

