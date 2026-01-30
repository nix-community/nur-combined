{
  fetchFromGitHub,
  stdenv,
  python3,
  python310,
  pkg-config,
  waf,
  eigen,
  libyaml,
  fftwFloat,
  ffmpeg_4,
  libsamplerate,
  taglib,
  chromaprint,
  gaia,
  libsForQt5,
  zlib,
}: let
  py3 = python3.withPackages (
    ps:
      with ps; [
        numpy
        distutils
      ]
  );
in
  stdenv.mkDerivation rec {
    pname = "essentia";
    version = "2.1_beta5";

    src = fetchFromGitHub {
      owner = "MTG";
      repo = "essentia";
      tag = "v${version}";
      hash = "sha256-nPw3KxN2vXgAGnQIC5pMxZ35hbveERmvzMLn7vgx4kU=";
    };

    patches = [
      ./0001-Replace-is-not-by-for-literals.patch
      ./0002-replace-waf-node-object-with-string.patch
      ./0003-add-eigen-to-includes.patch
      ./0004-replace-hardcoded-path-with-prefix.patch
    ];

    nativeBuildInputs = [
      pkg-config
      (waf.override {python3 = py3;}).hook
      # add one of these depending on the project:
      # cmake
      # autoconf
      # automake
      # libtool
      # gnumake
    ];

    buildInputs = [
      py3
      eigen
      libyaml
      fftwFloat
      ffmpeg_4
      libsamplerate
      taglib
      chromaprint
      gaia
      #for examples
      libsForQt5.qt5.qtbase
      libsForQt5.qt5.qttools
      zlib
    ];

    wafPath = "buildtools/bin/waf";
    wafConfigureFlags = "--build-static --with-examples --with-gaia";
    wafBuildFlags = "-v";

    dontWrapQtApps = true;

    # meta = {
    #   changelog = "https://github.com/wxWidgets/Phoenix/blob/wxPython-${version}/CHANGES.rst";
    #   description = "Cross platform GUI toolkit for Python, Phoenix version";
    #   homepage = "http://wxpython.org/";
    #   license = with lib.licenses; [
    #     lgpl2Plus
    #     wxWindowsException31
    #   ];
    # };
  }
