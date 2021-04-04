{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, git, libwebp, libjpeg_turbo
, zlib, libexif, ffmpeg, graphicsmagick }:
stdenv.mkDerivation rec {
  pname = "timg";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "hzeller";
    repo = pname;
    rev = "v${version}";
    sha256 = "1abnvsgmcnj6rib07smh94pf4ili1szqjcd8sp6wqph6gnhk1nn1";
  };

  nativeBuildInputs = [ cmake pkg-config git ];

  buildInputs = [ libwebp graphicsmagick libjpeg_turbo zlib libexif ffmpeg ];

  meta = with lib; {
    description = "Terminal image and video viewer";
    license = licenses.gpl2;
    homepage = "https://github.com/hzeller/timg";
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
