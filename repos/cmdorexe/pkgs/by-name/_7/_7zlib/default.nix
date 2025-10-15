{
  stdenv,
  lib,
  fetchFromGitHub,
  gcc,
  gnumake,
}:

stdenv.mkDerivation rec {
  pname = "_7zlib";
  version = "25.01";

  src = fetchFromGitHub {
    owner = "ip7z";
    repo = "7zip";
    rev = "5e96a8279489832924056b1fa82f29d5837c9469";
    sha256 = "sha256-uGair9iRO4eOBWPqLmEAvUTUCeZ3PDX2s01/waYLTwY=";
  };

  nativeBuildInputs = [ gcc ];

  buildPhase = ''
    make -C CPP/7zip/Bundles/Format7zF -f ../../cmpl_gcc.mak
  '';

  installPhase = ''
    mkdir -p $out/{lib,/usr/lib/p7zip/}
    cp -r CPP/7zip/Bundles/Format7zF/b/g/*.so $out/usr/lib/p7zip/
  '';

  meta = with lib; {
    # Changed from stdenv.lib to lib
    description = "7z format plugin from ip7z/7zip";
    homepage = "https://github.com/ip7z/7zip";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
