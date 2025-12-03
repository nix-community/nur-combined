{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  pkg-config,
  agg,
  zlib,
  python3,
  freetype,
  libjpeg,
  libheif,
  libtiff,
  libpng,
  giflib,
  openexr,
  expat,
  swig,
}:

stdenv.mkDerivation rec {
  pname = "exactimage";
  # $ curl -sI http://dl.exactcode.de/oss/exact-image/exact-image-1.2.1.tar.bz2 | grep ^Last-Modified:
  # Last-Modified: Wed, 03 Jan 2024 17:32:43 GMT
  version = "1.2.1";

  # https://svn.exactcode.de/exact-image/
  # http://dl.exactcode.de/oss/exact-image/
  # https://github.com/milahu/exactcode-exactimage
  src =
  if true then
  fetchurl {
    url = "http://dl.exactcode.de/oss/exact-image/exact-image-${version}.tar.bz2";
    hash = "sha256-eEPPNdtA86LK7T0LESVuIm7xYWkkTKLcHImvhqyKFIo=";
  }
  else
  fetchFromGitHub {
    owner = "milahu";
    repo = "exactcode-exactimage";
    rev = "v${version}";
    hash = "sha256-T/WrA3l+METGw05luhghWoDQgnNWKwwDsDKJv9TZ+Ys=";
  };

  /*
    # no:
    # INSTALL PYTHON module objdir/api/python/_ExactImage.so
    # install: cannot create regular file '/nix/store/sd81bvmch7njdpwx3lkjslixcbj5mivz-python3-3.13.4/lib/python3.13/site-packages/ExactImage.py': Permission denied
    # >>> import sysconfig; print(sysconfig.get_paths()["purelib"])
    # /nix/store/sd81bvmch7njdpwx3lkjslixcbj5mivz-python3-3.13.4/lib/python3.13/site-packages
    #
    # fix: ModuleNotFoundError: No module named 'distutils'
    # make it work with python 3.13
    # NOTE this requires python 3.12
    substituteInPlace api/python/Makefile \
      --replace \
        "python -c 'from distutils.sysconfig import get_python_lib; print (get_python_lib())'" \
        "python -c 'import sysconfig; print(sysconfig.get_paths()[\"purelib\"])'"

  */

  postPatch = ''
    # fix: install: Permission denied
    sed -i "s|^PYTHON_LIBDIR := .*$|PYTHON_LIBDIR := $out/${python3.sitePackages}|" api/python/Makefile
  '';

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    agg
    zlib
    python3
    freetype
    expat
    libjpeg
    libheif
    libtiff
    libpng
    giflib
    openexr
    expat
    swig
  ];

  /*
  preConfigure = ''
    substituteInPlace config/functions \
      --replace \
        'pkgcheck () {' \
        'pkgcheck () { set -x;' \
  '';
  */

  # https://salsa.debian.org/ecsv/exactimage/-/blob/debian/unstable/debian/rules
  configureFlags = [
    # Optional Features
    # --disable-FEATURE      do not include FEATURE (same as --enable-FEATURE=no)
    # --enable-FEATURE[=ARG] include FEATURE [ARG=yes]
    # "--enable-evasgl"
    # "--enable-tga"
    # "--enable-pcx"
    # "--enable-static"

    # Optional Packages
    # "--with-x11" # TODO
    "--with-freetype"
    # "--with-evas"
    "--with-libjpeg"
    # "--with-libjxl"
    "--with-libheif" # HEIF and AVIF format
    "--with-libtiff"
    "--with-libpng"
    # FIXME error: 'GifQuantizeBuffer' was not declared in this scope
    # https://sourceforge.net/p/giflib/bugs/132/
    # https://github.com/coin3d/simage/pull/33
    # https://github.com/mono/libgdiplus/pull/575
    # "--with-libgif"
    # "--with-jasper"
    "--with-openexr"
    # FXIME ld: objdir/codecs/codecs.a: in function `agg::svg::parser::parse(std::istream&)':
    #   (.text+0x20f9): undefined reference to `XML_ParserCreate'
    # "--with-expat" # XML parser for SVG
    # "--with-lcms"
    # "--with-bardecode"
    # "--with-lua"
    "--with-swig" # codegen
    # "--with-perl"
    "--with-python"
    # "--with-php"
    # "--with-ruby"
  ];

  meta = {
    # example use: hocr2pdf -i 001.tiff -o 001.pdf <001.hocr
    description = "A fast, modern and generic image processing library (bardecode, econvert, edentify, empty-page, hocr2pdf, optimize2bw)";
    homepage = "https://exactcode.com/opensource/exactimage/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "econvert";
    platforms = lib.platforms.all;
  };
}
