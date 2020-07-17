{ lib
, stdenv
, fetchFromGitHub
, gnumake
, curl
}:
stdenv.mkDerivation rec {

  pname = "spotify-adblock";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "abba23";
    repo = "spotify-adblock-linux";
    rev = "v${version}";
    sha256 = "0pqbsj87jcb7phkxzfkg44rhv125vhigmp1ar02yff93jqifcl2w";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "PREFIX=/usr/local" "PREFIX=$out"
    sed -i '/\};/i    "audio4-fa.spotifycdn.com", //audio' whitelist.h
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ curl ];

  meta = with lib; {
    description = "Spotify adblocker for Linux";
    license = licenses.mit;
    homepage = "https://github.com/abba23/spotify-adblock-linux";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
