{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  makeWrapper,
  cmake,
  ninja,
  pkg-config,
  m4,
  perl,
  bash,
  xdg-utils,
  zip,
  unzip,
  gzip,
  bzip2,
  gnutar,
  p7zip,
  xz,
  withTTYX ? true,
  libX11,
  withGUI ? true,
  wxGTK32,
  withUCD ? true,
  libuchardet,

  # Plugins
  withColorer ? true,
  spdlog,
  libxml2,
  withMultiArc ? true,
  libarchive,
  pcre,
  withNetRocks ? true,
  openssl,
  libssh,
  samba,
  libnfs,
  neon,
  withPython ? true,
  withArcLite ? true,
  callPackage,
  withHexitor ? true,
  withOpenWith ? true,
  python3Packages,
  _7zlib ? callPackage ../../_7/_7zlib { },
  ...
}:

let
    _7zso = _7zlib;
    buildid = "d77354eed8e48def181811da8a61f72044e678e9";
in
stdenv.mkDerivation rec {
  pname = "far2l";
  version = "2.7.0-${buildid}";

  src = fetchFromGitHub {
    owner = "elfmz";
    repo = "far2l";
    rev = "${buildid}";
    sha256 = "sha256-V1zuBtwIb8GVIvVPV7kXPBKZiaGFpG/ZUAdLKbbK+nU=";
  };
#    # arrows
#  patches = fetchpatch {
#      url = "https://github.com/elfmz/far2l/commit/05be077f53590ea00604be7c893233749af8b140.patch";
#      sha256 = "sha256-OR1/alSmuTHj7lMpth5JPMa9w49zbzUgwJMKlbQX6aY=";
#  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    m4
    perl
    makeWrapper
  ];

  buildInputs =
    lib.optional withTTYX libX11
    ++ lib.optional withGUI wxGTK32
    ++ lib.optional withUCD libuchardet
    ++ lib.optionals withColorer [
      spdlog
      libxml2
    ]
    ++ lib.optionals withMultiArc [
      libarchive
      pcre
    ]
    ++ lib.optionals withNetRocks [
      openssl
      libssh
      libnfs
      neon
    ]
    ++ lib.optional (withNetRocks && !stdenv.hostPlatform.isDarwin) samba # broken on darwin
    ++ lib.optionals withPython (
      with python3Packages;
      [
        python
        cffi
        debugpy
        pcpp
      ]
    ++ lib.optionals withArcLite [
        _7zso
    ]
    );

  postPatch = ''
    patchShebangs python/src/build.sh
    patchShebangs far2l/bootstrap/view.sh
  '';

  cmakeFlags = [
    (lib.cmakeBool "TTYX" withTTYX)
    (lib.cmakeBool "USEWX" withGUI)
    (lib.cmakeBool "USEUCD" withUCD)
    (lib.cmakeBool "COLORER" withColorer)
    (lib.cmakeBool "MULTIARC" withMultiArc)
    (lib.cmakeBool "NETROCKS" withNetRocks)
    (lib.cmakeBool "PYTHON" withPython)
    (lib.cmakeBool "ARCLITE" withArcLite)
    (lib.cmakeBool "HEXITOR" withHexitor)
    (lib.cmakeBool "OPENWITH" withOpenWith)

  ]
  ++ lib.optionals withPython [
    (lib.cmakeFeature "VIRTUAL_PYTHON" "python")
    (lib.cmakeFeature "VIRTUAL_PYTHON_VERSION" "python")
  ];

  runtimeDeps = [
    unzip
    zip
    p7zip
    xz
    gzip
    bzip2
    gnutar
  ]
  ++ lib.optionals withArcLite [
        _7zso
  ];

  postInstall = ''
    # Create symlink 7z.so to the expected location
    mkdir -p $out/{lib,/usr/lib/7zip/}
    ln -sf "${_7zso}/usr/lib/p7zip/7z.so" $out/lib/far2l/Plugins/arclite/plug/7z.so
    wrapProgram $out/bin/far2l \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  meta = with lib; {
    description = "Linux port of FAR Manager v2, a program for managing files and archives in Windows operating systems";
    homepage = "https://github.com/elfmz/far2l";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ hypersw ];
    platforms = platforms.unix;
  };
}
