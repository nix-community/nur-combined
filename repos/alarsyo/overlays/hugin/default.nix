final: prev: {
  # hugin needs glew-egl since wxGTK30 upgrade:
  # https://bugs.archlinux.org/task/75406
  hugin = prev.hugin.overrideAttrs (oldAttrs: {
    buildInputs = with final; [
      boost
      cairo
      exiv2
      fftw
      flann
      gettext
      glew
      ilmbase
      lcms2
      lensfun
      libjpeg
      libpng
      libtiff
      xorg.libX11
      xorg.libXi
      xorg.libXmu
      libGLU
      libGL
      openexr
      panotools
      sqlite
      vigra
      (wxGTK31.override {
        withEGL = false;
      })
      zlib
    ];
  });
}
