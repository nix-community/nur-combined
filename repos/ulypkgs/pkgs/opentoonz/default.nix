{
  boost,
  cmake,
  fetchFromGitHub,
  libglut,
  freetype,
  glew,
  libsForQt5,
  libjpeg,
  libmypaint,
  libpng,
  libusb1,
  lz4,
  xz,
  lzo,
  openblas,
  opencv,
  pkg-config,
  lib,
  stdenv,
  superlu,
  libtiff,
  zlib,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opentoonz";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "opentoonz";
    repo = "opentoonz";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2pF6TxEirCR2b0VPrlGZfpbTInp5lq7hfSQAflrNRdM=";
  };

  # instead of directly setting sourceRoot, use postUnpack to make other subdirs of src writable
  postUnpack = ''
    sourceRoot="$sourceRoot/toonz"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    boost
    libglut
    freetype
    glew
    libjpeg
    libmypaint
    libpng
    libusb1
    lz4
    xz
    lzo
    openblas
    opencv
    libsForQt5.qtbase
    libsForQt5.qtmultimedia
    libsForQt5.qtscript
    libsForQt5.qtserialport
    superlu
  ];

  cmakeDir = "../sources";
  cmakeFlags = [
    (lib.cmakeFeature "TIFF_INCLUDE_DIR" "${finalAttrs.passthru.libtiff.dev}/include")
    (lib.cmakeFeature "TIFF_LIBRARY" "${finalAttrs.passthru.libtiff.out}/lib/libtiff.so")
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
  ];

  preFixup = ''
    sed -i '/cp -r .*stuff/a\    chmod -R u+w "$HOME/.config/OpenToonz/stuff"' $out/bin/opentoonz
  '';

  passthru = {
    updateScript = nix-update-script { };

    # OpenToonz requires its fork's internal headers and custom TIFF tags.
    # Based on nixpkgs before 7e8ad0e785058bffbfa09df4512a62c58d34f581.
    libtiff = stdenv.mkDerivation (libtiffAttrs: {
      pname = "libtiff";
      version = "4.0.3";

      inherit (finalAttrs) src;
      sourceRoot = "${libtiffAttrs.src.name}/thirdparty/tiff-${libtiffAttrs.version}";

      outputs = [
        "bin"
        "dev"
        "out"
        "man"
        "doc"
      ];

      nativeBuildInputs = [ pkg-config ];
      propagatedBuildInputs = [
        zlib
        libjpeg
        xz
      ];

      postInstall = ''
        cp libtiff/{tif_config,tif_dir,tiffiop}.h $dev/include
      '';

      meta = libtiff.meta // {
        knownVulnerabilities = [
          ''
            Do not open untrusted files with Opentoonz:
            Opentoonz uses an old custom fork of libtiff from 2012 that is known to
            be affected by at least these 50 vulnerabilities:
              CVE-2012-4564 CVE-2013-4232 CVE-2013-4243 CVE-2013-4244 CVE-2014-8127
              CVE-2014-8128 CVE-2014-8129 CVE-2014-8130 CVE-2014-9330 CVE-2015-1547
              CVE-2015-8781 CVE-2015-8782 CVE-2015-8783 CVE-2015-8784 CVE-2015-8870
              CVE-2016-3620 CVE-2016-3621 CVE-2016-3623 CVE-2016-3624 CVE-2016-3625
              CVE-2016-3631 CVE-2016-3632 CVE-2016-3633 CVE-2016-3634 CVE-2016-3658
              CVE-2016-3945 CVE-2016-3990 CVE-2016-3991 CVE-2016-5102 CVE-2016-5314
              CVE-2016-5315 CVE-2016-5316 CVE-2016-5318 CVE-2016-5319 CVE-2016-5321
              CVE-2016-5322 CVE-2016-5323 CVE-2016-6223 CVE-2016-9453 CVE-2016-9532
              CVE-2017-9935 CVE-2017-9937 CVE-2018-10963 CVE-2018-5360
              CVE-2019-14973 CVE-2019-17546 CVE-2020-35521 CVE-2020-35522
              CVE-2020-35523 CVE-2020-35524
            More info at https://github.com/opentoonz/opentoonz/issues/4193
          ''
        ];
        maintainers = finalAttrs.meta.maintainers;
      };
    });
  };

  meta = {
    description = "Full-featured 2D animation creation software";
    homepage = "https://opentoonz.github.io/";
    changelog = "https://github.com/opentoonz/opentoonz/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "opentoonz";
  };
})
