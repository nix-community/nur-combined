{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "qtpbfimageplugin-styles";
  version = "2025-10-04";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = "qtpbfimageplugin-styles";
    rev = "c8ea3f84d5cfd1fb69632cdaca1f87c7c3d12303";
    hash = "sha256-0j89KF56G1je8xy0sTE4FzvUXDUxgE7BFb0hxNdqsJc=";
  };

  installPhase = ''
    install -dm755 $out
    cp -r * $out
  '';

  meta = {
    description = "QtPBFImagePlugin styles";
    homepage = "https://github.com/tumic0/qtpbfimageplugin-styles";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
}
