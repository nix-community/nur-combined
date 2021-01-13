{ stdenv
, fetchFromGitHub
, autoPatchelfHook, pkgconfig, cmake
, glib, libsndfile
}:

stdenv.mkDerivation rec {
  pname = "libinstpatch";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "swami";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-S1aWTsJwUpiab83PuLwnTfxFETtM4y7maE5PXxgkXV8=";
  };

  nativeBuildInputs = [ autoPatchelfHook pkgconfig cmake ];

  buildInputs = [ glib libsndfile ];

  cmakeFlags = [
    "-DLIB_SUFFIX=" # Install in $out/lib.
  ];

  meta = with stdenv.lib; {
    description = "Instrument file software library.";
    homepage = "https://github.com/swami/libinstpatch";
    license = licenses.lgpl21Plus;
    platforms = with platforms; linux;
  };
}
