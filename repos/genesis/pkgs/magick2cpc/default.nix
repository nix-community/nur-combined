{ stdenv, fetchFromGitHub, imagemagick, pkgconfig, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "magick2cpc-${version}";
  version = "2019-05-17";

  src = fetchFromGitHub {
    owner = "bignaux";
    repo = "Magick2CPC";
    rev = "abddf946863db8dddb82e4b139bdf30eb86f34e6";
    sha256 = "16412i9skdmi9a297dxwr6817wfwafbpx4vxfkks9pwx2jcmp75j";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ imagemagick ];

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "An image converter for CPC using ImageMagick.";
    license = licenses.gpl3;
    maintainers = with maintainers; [ genesis ];
    platforms = with platforms; linux; # possibly others, but only tested on Linux
  };
}
