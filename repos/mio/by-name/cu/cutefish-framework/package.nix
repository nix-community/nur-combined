{
  lib,
  mkCutefishDerivation,
  cutefish-toolkit,
  fetchgit,
  fetchurl,
  fontconfig,
  freetype,
  harfbuzz,
  icu,
  libpng,
  pipewire,
  systemd,
  lcms2,
  openjpeg,
  libjpeg,
  zlib,
  libhwy,
  abseil-cpp,
}:

let
  # Pinned by cutefish-framework/scripts/fetch-pdfium.sh. Only the folders the
  # pdf library is built from are checked out.
  pdfiumSrc = fetchgit {
    url = "https://pdfium.googlesource.com/pdfium";
    rev = "99da130a26ad610843d041a509efd8ea68cc05b7";
    sparseCheckout = [
      "constants"
      "core"
      "fpdfsdk"
      "fxjs"
      "public"
      "third_party/agg23"
      "third_party/bigint"
      "third_party/freetype"
    ];
    hash = "sha256-sVBWyzzQm5NtKZxAWtMjBP8U9sGZwoxGbU2psPaQ9Rg=";
  };

  # PDFium includes these by Chromium checkout paths. They are the files the
  # fetch script pulls from Chromium's build repository and the two header-only
  # libraries its DEPS names; everything else comes from nixpkgs.
  buildConfig = fetchurl {
    url = "https://chromium.googlesource.com/chromium/src/build/+/0c62137b8623a3fab2c6aa5d7c94f719b3aa31f6/build_config.h?format=TEXT";
    hash = "sha256-sSjSl4TYYe45m6czqSOITfr27dJU3KKOlkJOwZfAxZc=";
  };
  buildflag = fetchurl {
    url = "https://chromium.googlesource.com/chromium/src/build/+/0c62137b8623a3fab2c6aa5d7c94f719b3aa31f6/buildflag.h?format=TEXT";
    hash = "sha256-d/vJhIspkZ52oVSunPK3kVv0aDypQtFrQ+Q6f50fAH4=";
  };
  dragonbox = fetchurl {
    url = "https://chromium.googlesource.com/external/github.com/jk-jeon/dragonbox/+archive/beeeef91cf6fef89a4d4ba5e95d47ca64ccb3a44/include.tar.gz";
    hash = "sha256-1IELvboD1zelDSLz7Gr7Sj/c2thxcGuM5WfCPV3JP4U=";
  };
  fastFloat = fetchurl {
    url = "https://chromium.googlesource.com/external/github.com/fastfloat/fast_float/+archive/42f254836ee416ffcf2f4e6576260003ac33d48c/include.tar.gz";
    hash = "sha256-KPsxZk2LuMXudjL/KN+ebN2qar5oKI1wT4NmuOUp5sU=";
  };
in
mkCutefishDerivation {
  pname = "cutefish-framework";

  postPatch = ''
    substituteInPlace clients/networkmanager/vpn_utils.cpp \
      --replace-fail '{"/etc/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}' \
        '{"/etc/NetworkManager/VPN", "/run/current-system/sw/lib/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}'
    # Preset avatars are installed by cutefish-wallpapers and linked into the
    # system profile; the header's default directory is the upstream /usr one.
    substituteInPlace clients/accounts/account_picture.h \
      --replace-fail '"/usr/share/cutefish/avatars"' \
        '"/run/current-system/sw/share/cutefish/avatars"'
  '';

  preConfigure = ''
    mkdir -p third_party/pdfium-deps/build
    cp -a ${pdfiumSrc}/. third_party/pdfium
    chmod -R u+w third_party/pdfium
    # base64, because Gitiles serves single files that way.
    base64 -d ${buildConfig} > third_party/pdfium-deps/build/build_config.h
    base64 -d ${buildflag} > third_party/pdfium-deps/build/buildflag.h
    # The Gitiles archives hold the headers' own roots; PDFium includes them
    # through a checkout path that ends in include/.
    mkdir -p third_party/pdfium-deps/dragonbox/include third_party/pdfium-deps/fast_float/include
    tar xzf ${dragonbox} -C third_party/pdfium-deps/dragonbox/include
    tar xzf ${fastFloat} -C third_party/pdfium-deps/fast_float/include
  '';

  extraBuildInputs = [
    cutefish-toolkit
    fontconfig
    freetype
    harfbuzz
    icu
    libpng
    pipewire
    systemd
    lcms2
    openjpeg
    libjpeg
    zlib
    libhwy
    abseil-cpp
  ];

  meta = {
    description = "System-service clients, file operations and PDF documents for the Cutefish desktop";
  };
}
