# based on https://github.com/GJDuck/e9patch/blob/master/build.sh

{ lib
, stdenv
, fetchFromGitHub
, xxd
}:

stdenv.mkDerivation rec {
  pname = "e9patch";
  version = "1.0.0-rc8";

  src =
  if true then
  # https://github.com/GJDuck/e9patch/pull/73
  # fix: error: 'SIZE_MAX' was not declared in this scope
  # fix: warning: format '%zu' expects argument of type 'size_t', but argument 5 has type 'int'
  fetchFromGitHub {
    owner = "milahu";
    repo = "e9patch";
    rev = "171a74b91e6a52565930f2967816c69ac00e336d";
    hash = "sha256-lf5RTQXyYZxKu7B6PnBk5wuLdTAeNlM0hzWvZwk1hoA=";
  }
  else
  fetchFromGitHub {
    owner = "GJDuck";
    repo = "e9patch";
    /*
    rev = "v${version}";
    hash = "sha256-/Q6tm4VqiqzQWZVX5CYoTPlntzoP/I2kK9YZaKIeu/c=";
    */
    rev = "8d5e2e9f04ea05b94d5d3e29fbb39c5f37c27c8d";
    hash = "sha256-CKssutKRAc3vUxbaYoQrfx0iF3R3qilCnQFIs7j8+Rw=";
  };

  zydis-src = fetchFromGitHub {
    owner = "zyantific";
    repo = "zydis";
    rev = "3f5a3ad8e16658c62d7033e9373232d19480d3cc";
    hash = "sha256-5afvMiUMuYCmxx6Gy1jHh2z/me4ZMzyNmWNf6VatPl0=";
  };

  zycore-src = fetchFromGitHub {
    owner = "zyantific";
    repo = "zycore-c";
    rev = "5c341bf141fe9274c9037c542274ead19fb645d8";
    hash = "sha256-nyDlXbeTDmnvncvj8tXmRhDwvX/xW9PauP1wMskzdVM=";
  };

  # TODO cp --no-preserve=blah
  postUnpack = ''
    pushd $sourceRoot >/dev/null

    cp -r ${zydis-src} zydis
    chmod -R +w zydis

    rm -rf zydis/dependencies/zycore
    cp -r ${zycore-src} zydis/dependencies/zycore
    chmod -R +w zydis/dependencies/zycore

    cat << EOF > zydis/include/ZydisExportConfig.h
    #ifndef ZYDIS_EXPORT_H
    #define ZYDIS_EXPORT_H
    #define ZYDIS_EXPORT
    #define ZYDIS_NO_EXPORT
    #define ZYDIS_DEPRECATED __attribute__ ((__deprecated__))
    #define ZYDIS_DEPRECATED_EXPORT ZYDIS_EXPORT ZYDIS_DEPRECATED
    #define ZYDIS_DEPRECATED_NO_EXPORT ZYDIS_NO_EXPORT ZYDIS_DEPRECATED
    #define ZYDIS_NO_DEPRECATED
    #endif
    EOF

    cat << EOF > zydis/include/ZycoreExportConfig.h
    #ifndef ZYCORE_EXPORT_H
    #define ZYCORE_EXPORT_H
    #define ZYCORE_EXPORT
    #define ZYCORE_NO_EXPORT
    #define ZYCORE_DEPRECATED __attribute__ ((__deprecated__))
    #define ZYCORE_DEPRECATED_EXPORT ZYCORE_EXPORT ZYCORE_DEPRECATED
    #define ZYCORE_DEPRECATED_NO_EXPORT ZYCORE_NO_EXPORT ZYCORE_DEPRECATED
    #define ZYCORE_NO_DEPRECATED
    #endif
    EOF

    popd >/dev/null
  '';

  nativeBuildInputs = [
    xxd
  ];

  buildPhase = ''
    runHook preBuild
    make -j $NIX_BUILD_CORES -f Makefile.zydis
    make -j $NIX_BUILD_CORES tool release
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv -v e9patch $out/bin
    mv -v e9tool $out/bin

    mkdir -p $out/share/man/man1
    mv -v doc/e9*.1 $out/share/man/man1

    mkdir -p $out/share/doc/e9patch
    mv -v doc/* $out/share/doc/e9patch
    cp -r examples $out/share/doc/e9patch/examples

    mkdir -p $out/include/e9tool
    mv -v src/e9tool/e9tool.h $out/include/e9tool
    mv -v src/e9tool/e9plugin.h $out/include/e9tool

    mkdir -p $out/include/e9compile
    cp -v examples/stdlib.c $out/include/e9compile
    mv -v src/e9patch/e9loader.h $out/include/e9compile
  '';

  meta = with lib; {
    description = "A powerful static binary rewriting tool";
    homepage = "https://github.com/GJDuck/e9patch";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "e9patch";
    platforms = platforms.all;
  };
}
