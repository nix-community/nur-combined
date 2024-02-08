# based on https://github.com/GJDuck/e9patch/blob/master/build.sh

{ lib
, stdenv
, fetchFromGitHub
, xxd
, gcc
, binutils
, coreutils
, gnugrep
}:

stdenv.mkDerivation rec {
  pname = "e9patch";
  version = "1.0.0-rc8";

  src = fetchFromGitHub {
    owner = "GJDuck";
    repo = "e9patch";
    # https://github.com/GJDuck/e9patch/pull/76
    rev = "6048a213a7ac608fc26a8abec2ebf308215fab34";
    hash = "sha256-L9EB37lxM3qUDsBkOHQVA1VAZKVXm4nkyZw57biT6NE=";
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

  runtimeInputs = [
    gcc
    binutils # objdump readelf
    coreutils # head
    gnugrep
  ];

  postPatch = ''
    echo "patching e9compile.sh"
    substituteInPlace e9compile.sh \
      --replace "#!/bin/sh" "#!/bin/sh"$'\n'"export PATH='${lib.makeBinPath runtimeInputs}':\"$PATH\"" \
      --replace 'include_examples_path="examples/"' "include_examples_path='$out/share/doc/e9patch/examples'"
  '';

  nativeBuildInputs = [
    xxd
  ];

  buildPhase = ''
    runHook preBuild

    echo "building libZydis.a"
    make -j $NIX_BUILD_CORES -f Makefile.zydis

    echo "building e9tool and e9patch"
    make -j $NIX_BUILD_CORES tool release

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv -v e9patch $out/bin
    mv -v e9tool $out/bin
    mv -v e9compile.sh $out/bin/e9compile

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
