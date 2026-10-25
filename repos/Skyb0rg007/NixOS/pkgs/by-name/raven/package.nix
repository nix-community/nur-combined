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
  libpng,
  liberation_ttf,
  libxkbcommon,
  openssl,
  pixman,
  skia,
  vulkan-headers,
  vulkan-loader,
  wayland,
}:
let
  # Pinned ReactOS source the guest components are built from (scripts/provision-*.py)
  reactosSource = fetchurl {
    name = "reactos-dacf2a6c47fa562799f9c8a41ab6d5c558556558.tar.gz";
    url = "https://codeload.github.com/reactos/reactos/tar.gz/dacf2a6c47fa562799f9c8a41ab6d5c558556558";
    hash = "sha256-U3O7u2BUHLKkngrLUzYOEhjU9dVsMfkYezQbn8Ftqmk=";
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
  version = "0-unstable-2026-10-24";

  src = fetchFromGitHub {
    owner = "mirkobrombin";
    repo = "raven";
    rev = "8966a3a2927eb7b3c68ad553043032c771266c89";
    hash = "sha256-BX100t7b/cjJdkZOJNROHam8Exudx2suZxO8OhMbHG4=";
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
    # objcopy sits beside the compiler, but "gcc" also appears in the wrapper's store path
    substituteInPlace scripts/generate-vulkan-{layout32,thunk32}.py \
      --replace-fail 'compiler.replace("gcc", "objcopy")' 'compiler.removesuffix("gcc") + "objcopy"'
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
    libpng
    libxkbcommon
    openssl
    pixman
    vulkan-headers
    vulkan-loader
    wayland
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
    # Guest components built from the pinned ReactOS source
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

      # Some sources call undeclared functions, an error since GCC 14
      env = {
        NIX_CFLAGS_COMPILE_x86_64_w64_mingw32 = "-fpermissive";
        NIX_CFLAGS_COMPILE_i686_w64_mingw32 = "-fpermissive";
      };

      buildPhase = ''
        runHook preBuild

        # MinGW-w64 >= 14 wraps these msvcrt.dll functions in libmingwex instead of importing them, and
        # moved the i686 LZ imports from kernel32 to lz32, but the components link with -nostdlib
        # against Raven's own msvcrt.dll and kernel32.dll
        for triple in x86_64-w64-mingw32 i686-w64-mingw32; do
          compat=$NIX_BUILD_TOP/compat-$triple
          mkdir -p $compat
          printf '%s\n' 'LIBRARY msvcrt.dll' EXPORTS _assert iswctype wcstok_s __getmainargs __wgetmainargs \
            > $compat/msvcrt.def
          $triple-dlltool -d $compat/msvcrt.def -l $compat/libmsvcrt-compat.a
          ldflags="-L$compat -lmsvcrt-compat"
          if [[ $triple == i686-* ]]; then
            printf '%s\n' 'LIBRARY kernel32.dll' EXPORTS LZStart@0 LZSeek@12 LZRead@12 LZOpenFileW@12 \
              LZOpenFileA@12 LZInit@4 LZDone@0 LZCopy@8 LZClose@4 GetExpandedNameW@8 GetExpandedNameA@8 \
              CopyLZFile@8 > $compat/kernel32.def
            $triple-dlltool -k -d $compat/kernel32.def -l $compat/libkernel32-compat.a
            ldflags+=" -lkernel32-compat"
          fi
          export NIX_LDFLAGS_AFTER_''${triple//-/_}="$ldflags"
        done

        # The import libraries the components link against are named after the output directory
        python3 scripts/provision-rtl.py --archive ${reactosSource} --output components/rtl
        for arch in x64 x86; do
          python3 scripts/provision-controls.py --archive ${reactosSource} --arch $arch --output components/controls-$arch
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

    # The pinned ReactOS revision and certificates in scripts/provision-*.py must be bumped by hand
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Runs Windows applications on Linux without a virtual machine";
    homepage = "https://useraven.org/";
    license =
      with lib.licenses;
      AND [
        mit # Raven, libxml2, ReactOS PSEH
        gpl2Plus # ReactOS RTL (raven-rtl.dll), user32 (raven-user32.dll) and UTF-8 codec
        lgpl21Plus # ReactOS/Wine DLLs, ReactOS non-client drawing
        bsd2 # ReactOS RTL (COPYING.ARM)
        unicode-30 # Unicode decomposition data, ReactOS c_1252.txt
        zlib # zlib (cabinet.dll, libpng.dll, libxslt.dll), DXVK
        libpng2 # libpng.dll
        ijg # libjpeg.dll
        libtiff # libtiff.dll
        x11 # libxslt.dll
        publicDomain # win-iconv (msxml3.dll)
        # libxml2 dict.c and list.c (msxml3.dll, libxslt.dll)
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
