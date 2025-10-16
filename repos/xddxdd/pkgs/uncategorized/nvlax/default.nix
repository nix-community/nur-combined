{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchurl,
  cmake,
  ninja,
  enableNvidia530Patch ? false,
}:
let
  zycoreOld = stdenv.mkDerivation (finalAttrs: {
    pname = "zycore";
    version = "636bb29945c94ffe4cedb5b6cc797e42c98de3af";
    src = fetchFromGitHub {
      owner = "zyantific";
      repo = "zycore-c";
      rev = finalAttrs.version;
      hash = "sha256-Rtg5nXj4Cplr1xr3lz8lexzmkvQL9v75a6Blc0f+To0=";
    };

    nativeBuildInputs = [ cmake ];
    cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

    preConfigure = ''
      sed -i 's#''${PACKAGE_PREFIX_DIR}/##' cmake/zycore-config.cmake.in
    '';
  });

  zydisOld = stdenv.mkDerivation (finalAttrs: {
    pname = "zydis";
    version = "55dd08c210722aed81b38132f5fd4a04ec1943b5";
    src = fetchFromGitHub {
      owner = "zyantific";
      repo = "zydis";
      rev = finalAttrs.version;
      hash = "sha256-PU++CMQ8zlaTt4q2cHfHLcHRoM2UgzvW8XNrgN6hbrg=";
    };

    nativeBuildInputs = [ cmake ];
    buildInputs = [ zycoreOld ];

    cmakeFlags = [
      "-DZYDIS_SYSTEM_ZYCORE=ON"
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ];
    preConfigure = ''
      sed -i 's#''${PACKAGE_PREFIX_DIR}/##' cmake/zydis-config.cmake.in
    '';
  });

  liefOld = stdenv.mkDerivation (finalAttrs: {
    pname = "lief";
    version = "b65e7cca03ec4cd91f1d7125e717d01635ea81ba";
    src = fetchFromGitHub {
      owner = "lief-project";
      repo = "LIEF";
      rev = "b65e7cca03ec4cd91f1d7125e717d01635ea81ba";
      hash = "sha256-kYTiSyvcOXywHVstGkKz/Adeztj0z+fLHYIp4Qk83i4=";
    };

    nativeBuildInputs = [
      cmake
      ninja
    ];

    env.CXXFLAGS = "-include cstdint";

    cmakeFlags = [
      "-DLIEF_PYTHON_API=OFF"
      "-DLIEF_EXAMPLES=OFF"
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ];

    # https://github.com/lief-project/LIEF/issues/770
    patches = [ ./lief.patch ];
  });

  ppkAssertOld = fetchFromGitHub {
    owner = "gpakosz";
    repo = "PPK_ASSERT";
    rev = "833b8b7ea49aea540a49f07ad08bf0bae1faac32";
    hash = "sha256-gGhqhdPMweFjhGPMGza5MwEOo5cJKrb5YrskjCvWX3w=";
  };

  nvidia530Patch = fetchurl {
    url = "https://aur.archlinux.org/cgit/aur.git/plain/530-NVENC.patch?h=nvlax-git";
    sha256 = "0r1p423x3n12xz0nvdvnyjmf1v6w8908nd0fkg6r00yj29fgzx50";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nvlax";
  version = "unstable-2021-10-29";
  src = fetchFromGitHub {
    owner = "illnyang";
    repo = "nvlax";
    rev = "b3699ad40c4dfbb9d46c53325d63ae8bf4a94d7f";
    hash = "sha256-xNZnMa4SFUFwnJAOruez9JxnCC91htqzR5HOqD4RZtc=";
  };

  patches = [ ./nvlax-cpm.patch ] ++ lib.optionals enableNvidia530Patch [ nvidia530Patch ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    zycoreOld
    zydisOld
    liefOld
  ];
  cmakeFlags = [
    "-DPPK_ASSERT_SOURCE_DIR=${ppkAssertOld}"
    "-DLIEF_INCLUDE_DIRS=${liefOld}/include"
    "-DLIEF_LIBRARIES=${liefOld}/lib/libLIEF.a"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  meta = {
    mainProgram = "nvlax_encode";
    maintainers = with lib.maintainers; [ xddxdd ];
    description =
      "Future-proof NvENC & NvFBC patcher"
      + lib.optionalString enableNvidia530Patch " (for NVIDIA driver >= 530)";
    homepage = "https://github.com/illnyang/nvlax";
    license = with lib.licenses; [ gpl3Only ];
    # broken = true;
  };
})
