{
  lib,
  stdenv,
  fetchurl,
  omniorb,
  pkg-config,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "omniORBpy";
  version = "4.3.2";

  src = fetchurl {
    url = "http://downloads.sourceforge.net/omniorb/${finalAttrs.pname}-${finalAttrs.version}.tar.bz2";
    hash = "sha256-y1cX1BKhAbr0MPWYysfWkjGITa5DctjirfPd7rxffrs=";
  };

  propagatedBuildInputs = [ omniorb ];

  nativeBuildInputs = [ pkg-config ];

  configureFlags = [
    "--with-omniorb=${omniorb}"
    "PYTHON_PREFIX=$out"
    "PYTHON=${lib.getExe python3Packages.python}"
  ];

  postInstall = ''
    rm $out/${python3Packages.python.sitePackages}/omniidl_be/__init__.py
  '';

  meta = with lib; {
    homepage = "http://omniorb.sourceforge.net";
    license = with licenses; [
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [ nim65s ];
    platforms = platforms.unix;
  };
})
