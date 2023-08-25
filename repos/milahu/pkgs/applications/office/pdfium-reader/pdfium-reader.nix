{ lib
, stdenv
, fetchFromGitHub
, cmake
, pdfium
, glfw
, glew
, xorg
, pkg-config
, gtk3
#, pcre2 # for gtk3
#, utillinux # mount for gtk3
, freeglut # GL/glut.h
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "pdfium-reader";
  version = "unstable-2023-08-25";

  src = fetchFromGitHub {
    /*
    owner = "ikuokuo";
    repo = "pdfium-reader";
    rev = "635ef925f288dcd8fdf684e62edf2bcb44379648";
    hash = "sha256-dBmbVpRiOWunvGO9VbPJc6fkduD0ekUUiMJV2qh3OVQ=";
    */
    # fix build errors
    # https://github.com/ikuokuo/pdfium-reader/pull/2
    # https://github.com/milahu/pdfium-reader/tree/fix-build-errors
    owner = "milahu";
    repo = "pdfium-reader";
    rev = "2644cfe868a5a80b1df1987c4e048f0d336d310d";
    hash = "sha256-3InaH7/ydKMk+GgSq203ZzU5tUC2Z2J+Gakg9DoC8aI=";
    # TODO avoid git modules. create update.sh to generate sources.json
    # and merge sources trees in unpackPhase
    # https://github.com/ikuokuo/pdfium-reader/tree/main/third_party
    fetchSubmodules = true;
  };

  # TODO use system's libpdfium.so
  # patch CMakeLists.txt: set(PDFium_DIR ${MY_3RDPARTY}/pdfium-${HOST_OS}-${HOST_ARCH})
  postPatch = ''
    ln -s ${pdfium} third_party/pdfium-linux-x64
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # fix: pdfium_reader: GLib-GIO-ERROR: No GSettings schemas are installed on the system
    wrapGAppsHook
  ];

  buildInputs = [
    pdfium
    glfw
    glew
    xorg.libX11
    xorg.libXxf86vm
    gtk3
    #pcre2 # for gtk3
    #utillinux # mount for gtk3
    freeglut # GL/glut.h
  ];

  /*
    default install:

    bin/pdfium_reader
    bin/ui/glfw_demo
    bin/ui/imgui_demo
    bin/pdfium_start
    bin/pdf/pdf_info
    bin/pdf/pdf_render
    bin/libpdfium.so
    include/nfd.h
    include/nfd.hpp
    lib/libnfd.a

    the demos are useless
    "pdfium_start input.pdf" does nothing
    libpdfium.so should be in lib
  */

  postInstall = ''
    cd $out
    # include/nfd.h
    # include/nfd.hpp
    # lib/libnfd.a
    rm -rf lib include
    mkdir opt
    mv bin opt/pdfium-reader
    mkdir bin
    ln -sr opt/pdfium-reader/{pdfium_reader,pdf/pdf_render,pdf/pdf_info} bin
  '';

  meta = with lib; {
    description = "PDFium Reader";
    homepage = "https://github.com/ikuokuo/pdfium-reader";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
