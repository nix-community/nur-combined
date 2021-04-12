{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, git, libwebp, libjpeg_turbo
, zlib, libexif, ffmpeg, graphicsmagick }:
stdenv.mkDerivation rec {
  pname = "timg";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "hzeller";
    repo = pname;
    rev = "v${version}";
    sha256 = "10qhjfkbazncmj07y0a6cpmi7ki0l10qzpvi2zh8369yycqqxr8y";
  };

  nativeBuildInputs = [ cmake pkg-config git ];

  buildInputs = [ libwebp graphicsmagick libjpeg_turbo zlib libexif ffmpeg ];

  cmakeFlags = [
    # openslide is not packaged yet
    "-DWITH_OPENSLIDE_SUPPORT=OFF"
  ];

  meta = with lib; {
    description = "Terminal image and video viewer";
    license = licenses.gpl2;
    homepage = "https://github.com/hzeller/timg";
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
