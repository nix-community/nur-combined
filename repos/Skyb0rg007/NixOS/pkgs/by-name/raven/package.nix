{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  linkFarm,
  nix-update-script,
  bison,
  clang,
  cmake,
  flex,
  ninja,
  pkg-config,
  pkgsCross,
  python3,
  wayland-scanner,
  wine64Packages,
  dxvk,
  freetype,
  libffi,
  libGL,
  libGLU,
  libpng,
  liberation_ttf,
  libxau,
  libxcb,
  libxdmcp,
  libxkbcommon,
  openssl,
  pixman,
  skia,
  vulkan-headers,
  vulkan-loader,
  wayland,
  wayland-protocols,
}:
let
  # Pinned ReactOS source the guest components are built from (scripts/provision-*.py)
  reactosSource = fetchurl {
    name = "reactos-dacf2a6c47fa562799f9c8a41ab6d5c558556558.tar.gz";
    url = "https://codeload.github.com/reactos/reactos/tar.gz/dacf2a6c47fa562799f9c8a41ab6d5c558556558";
    hash = "sha256-U3O7u2BUHLKkngrLUzYOEhjU9dVsMfkYezQbn8Ftqmk=";
  };

  # Pinned SQLite amalgamation winsqlite3.dll is built from (scripts/provision-sqlite.py)
  sqliteAmalgamation = fetchurl {
    url = "https://www.sqlite.org/2026/sqlite-amalgamation-3540100.zip";
    hash = "sha256-CpyONDUtrUYAaqgoNtU4O/+dxryc5aYFU8Baow5q0fk=";
  };

  # Code signing roots installer signatures are checked against (scripts/provision-roots.py)
  rootCertificates = linkFarm "raven-root-certificates" (
    lib.mapAttrs
      (
        name: hash:
        fetchurl {
          url = "http://www.microsoft.com/pki/certs/${name}";
          inherit hash;
        }
      )
      {
        "MicrosoftRootAuthority.crt" = "sha256-84QG5UDXqdkMtKlHkplkD/tt+eIk7MegHA2VWNja130=";
        "MicrosoftRootCert.crt" = "sha256-iF3mTDQOPqcGWPAeEUX5V/zaJ6q+6hq5+qn9sBAtQHc=";
        "MicRooCerAut_2010-06-23.crt" = "sha256-31Rb+RmiQ5w2mDtUzfyQPfpPN9OZbY2EtMMe7G88Fj4=";
        "MicRooCerAut2011_2011_03_22.crt" = "sha256-hH32p4SXlD8n/HLrk/mmNzIKArVh0KkbCeh6eAftfGE=";
      }
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "raven";
  version = "0-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "mirkobrombin";
    repo = "raven";
    rev = "63530b32db4bdde965b8234f3072a19437808c7a";
    hash = "sha256-wlBVYICDVDHF+gP2cTsdYuJgj0hsbE16bBc5+UlkhaI=";
  };

  # Configure-time fixture provisioning downloads and builds test programs
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '--output ''${RAVEN_TESTDATA_DIR} ''${FIXTURE_ARGUMENTS}' \
        '--output ''${RAVEN_TESTDATA_DIR} --data-only --skip-downloads'
    # Raven builds Skia's path ops itself because its own Skia excludes them; nixpkgs' does not
    substituteInPlace native/CMakeLists.txt \
      --replace-fail 'file(GLOB RAVEN_SKIA_PATHOPS ''${RAVEN_SKIA_SOURCE}/src/pathops/*.cpp)' \
        'set(RAVEN_SKIA_PATHOPS)'
    # Raven pins Ubuntu's build of the fonts; nixpkgs builds them from source
    substituteInPlace native/CMakeLists.txt \
      --replace-fail 'if(NOT ACTUAL_FONT_HASH STREQUAL FONT_HASH)' 'if(FALSE)'
  '';

  cmakeFlags =
    let
      inherit (finalAttrs.passthru) components;
    in
    [
      (lib.cmakeFeature "RAVEN_VK_XML" "${vulkan-headers}/share/vulkan/registry/vk.xml")
      (lib.cmakeFeature "RAVEN_SKIA_SOURCE" "${skia.src}")
      (lib.cmakeFeature "RAVEN_SKIA_LIBRARY" "${lib.getLib skia}/lib/libskia.so")
      (lib.cmakeFeature "RAVEN_FONT_DIRECTORY" "${liberation_ttf}/share/fonts/truetype")
      (lib.cmakeFeature "RAVEN_ROOT_CERTIFICATE_DIRECTORY" "${rootCertificates}")
      (lib.cmakeFeature "RAVEN_RTL_COMPONENT_PATH" "${components}/rtl/raven-rtl.dll")
      (lib.cmakeFeature "RAVEN_CONTROLS_COMPONENT_DIR" "${components}/controls-x64")
      (lib.cmakeFeature "RAVEN_CONTROLS32_COMPONENT_DIR" "${components}/controls-x86")
      (lib.cmakeFeature "RAVEN_INSTALLER_COMPONENT_DIR" "${components}/installer-x64")
      (lib.cmakeFeature "RAVEN_INSTALLER32_COMPONENT_DIR" "${components}/installer-x86")
      (lib.cmakeFeature "RAVEN_SQLITE_COMPONENT_DIR" "${components}/sqlite")
    ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    pkgsCross.mingw32.buildPackages.gcc
    pkgsCross.mingwW64.buildPackages.gcc
    python3
    wayland-scanner
  ];

  buildInputs = [
    freetype
    libGL
    libGLU
    libpng
    libxcb
    libxkbcommon
    # Private requirements of wayland-client.pc and xcb.pc, which pkg_check_modules also resolves
    libffi
    libxau
    libxdmcp
    openssl
    pixman
    vulkan-headers
    vulkan-loader
    wayland
    wayland-protocols
  ];

  # `all` also builds hundreds of test fixtures, some of which fail to build with GCC 16
  ninjaFlags = [
    "raven"
    "raven-bootstrap"
    "intl_nls"
    "x86_ucrt_component"
    "mscoree_component"
    "root_certificates"
    "installer_components_64"
    "installer_components_32"
    "sqlite_component"
    "icu_component"
  ];

  # The runtime loads its components from beside its own executable
  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/raven $out/bin
    pushd native
    cp -r raven raven-bootstrap *.dll *.exe *.nls x86 roots $out/libexec/raven/
    popd
    cp ${dxvk.bin}/x64/*.dll $out/libexec/raven/
    ln -s ../libexec/raven/raven $out/bin/raven

    runHook postInstall
  '';

  passthru = {
    # Guest components built ahead of the main build, some from the pinned ReactOS source
    components = stdenv.mkDerivation {
      pname = "raven-components";
      inherit (finalAttrs) version src;

      nativeBuildInputs = [
        bison
        clang
        flex
        pkgsCross.mingw32.buildPackages.gcc
        pkgsCross.mingwW64.buildPackages.gcc
        python3
        wine64Packages.minimal # widl
      ];

      buildPhase = ''
        runHook preBuild

        # The import libraries the components link against are named after the output directory
        python3 scripts/provision-rtl.py --output components/rtl
        python3 scripts/provision-sqlite.py --archive ${sqliteAmalgamation} --output components/sqlite
        for arch in x64 x86; do
          python3 scripts/provision-controls.py --arch $arch --output components/controls-$arch
          python3 scripts/provision-installer.py --archive ${reactosSource} --arch $arch --output components/installer-$arch
        done

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        cp -r components $out
        runHook postInstall
      '';
    };

    # The pinned ReactOS revision, SQLite release and certificates in scripts/provision-*.py must be bumped by hand
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Runs Windows applications on Linux without a virtual machine";
    homepage = "https://useraven.org/";
    license =
      with lib.licenses;
      AND [
        gpl3Plus # Raven host (raven, raven-bootstrap)
        mit # Raven guest components, libxml2 (msxml3.dll)
        gpl2Only # ReactOS-derived installer components
        lgpl21Plus # ReactOS/Wine headers and IDL in the installer components
        unicode-30 # Unicode decomposition data, code page tables
        zlib # zlib (cabinet.dll, libpng.dll, libtiff.dll, msxml3.dll), DXVK
        libpng2 # libpng.dll
        ijg # libjpeg.dll, libtiff.dll
        libtiff # libtiff.dll
        x11 # libxslt (msxml3.dll)
        publicDomain # win-iconv (msxml3.dll)
        blessing # SQLite (winsqlite3.dll)
        # libxml2 dict.c and list.c (msxml3.dll)
        (mkLicense {
          shortName = "isc-veillard";
          spdxId = "ISC-Veillard";
          fullName = "ISC Veillard variant";
        })
      ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "raven";
  };
})
