{ stdenv
, lib
, fetchFromGitHub
, fetchurl
, cmake
, lief
, ...
}:

let
  zycoreOld = stdenv.mkDerivation rec {
    pname = "zycore";
    version = "636bb29945c94ffe4cedb5b6cc797e42c98de3af";
    src = fetchFromGitHub {
      owner = "zyantific";
      repo = "zycore-c";
      rev = version;
      sha256 = "sha256-Rtg5nXj4Cplr1xr3lz8lexzmkvQL9v75a6Blc0f+To0=";
    };

    nativeBuildInputs = [ cmake ];

    preConfigure = ''
      sed -i 's#''${PACKAGE_PREFIX_DIR}/##' cmake/zycore-config.cmake.in
    '';
  };

  zydisOld = stdenv.mkDerivation rec {
    pname = "zydis";
    version = "55dd08c210722aed81b38132f5fd4a04ec1943b5";
    src = fetchFromGitHub {
      owner = "zyantific";
      repo = "zydis";
      rev = version;
      sha256 = "sha256-PU++CMQ8zlaTt4q2cHfHLcHRoM2UgzvW8XNrgN6hbrg=";
    };

    nativeBuildInputs = [ cmake ];
    buildInputs = [ zycoreOld ];

    cmakeFlags = [ "-DZYDIS_SYSTEM_ZYCORE=ON" ];
    preConfigure = ''
      sed -i 's#''${PACKAGE_PREFIX_DIR}/##' cmake/zydis-config.cmake.in
    '';
  };

  liefOld = lief.overrideAttrs (old: {
    version = "b65e7cca03ec4cd91f1d7125e717d01635ea81ba";
    src = fetchFromGitHub {
      owner = "lief-project";
      repo = "LIEF";
      rev = "b65e7cca03ec4cd91f1d7125e717d01635ea81ba";
      sha256 = "sha256-kYTiSyvcOXywHVstGkKz/Adeztj0z+fLHYIp4Qk83i4=";
    };

    # https://github.com/lief-project/LIEF/issues/770
    patches = [ ./nvlax-lief-setuptools.patch ];
  });

  ppkAssertOld = fetchFromGitHub {
    owner = "gpakosz";
    repo = "PPK_ASSERT";
    rev = "833b8b7ea49aea540a49f07ad08bf0bae1faac32";
    sha256 = "sha256-gGhqhdPMweFjhGPMGza5MwEOo5cJKrb5YrskjCvWX3w=";
  };
in
stdenv.mkDerivation {
  pname = "nvlax";
  version = "b3699ad40c4dfbb9d46c53325d63ae8bf4a94d7f";
  src = fetchFromGitHub {
    owner = "illnyang";
    repo = "nvlax";
    rev = "b3699ad40c4dfbb9d46c53325d63ae8bf4a94d7f";
    sha256 = "sha256-xNZnMa4SFUFwnJAOruez9JxnCC91htqzR5HOqD4RZtc=";
  };

  patches = [ ./nvlax-cpm.patch ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ zycoreOld zydisOld liefOld ];
  cmakeFlags = [ "-DPPK_ASSERT_SOURCE_DIR=${ppkAssertOld}" ];

  meta = with lib; {
    description = "Future-proof NvENC & NvFBC patcher";
    homepage = "https://github.com/illnyang/nvlax";
    license = with licenses; [ gpl3Only ];
  };
}
