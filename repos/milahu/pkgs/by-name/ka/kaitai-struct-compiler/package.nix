{
  lib,
  stdenv,
  mkSbtDerivation,
  fetchFromGitHub,
  sbt,
  jdk,
  makeWrapper,
  unzip,
}:

mkSbtDerivation rec {
  pname = "kaitai-struct-compiler";
  version = "0.11-unstable-2025-07-26";

  # https://github.com/kaitai-io/kaitai_struct/issues/1060
  # https://github.com/kaitai-io/kaitai_struct_compiler/tree/serialization
  src = fetchFromGitHub {
    owner = "kaitai-io";
    repo = "kaitai_struct_compiler";
    rev = "4066d1e2d71238b2f37bd6a75e20b1271b7ae14d";
    hash = "sha256-/9bOIDq1mc2XrEWLJyYB56X978aPA6olwh/KFNaPkRo=";
  };

  depsSha256 = "sha256-IDYyf/AUU/bSAOmTc5LsZnRJh9NQ6SnQP8flH/yQiSE=";

  # default is "tar+zstd"...
  depsArchivalStrategy = "copy";

  # depsOptimize = false;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  # https://doc.kaitai.io/developers.html#_building_for_jvm
  # the default buildPhase is "sbt compile" but that produces only *.java files
  buildPhase = ''
    sbt compilerJVM/universal:packageBin
  '';

  installPhase = ''
    mkdir $out
    unzip jvm/target/universal/kaitai-struct-compiler-*.zip
    cp -r kaitai-struct-compiler-*/* $out
    rm $out/bin/kaitai-struct-compiler.bat
    wrapProgram $out/bin/kaitai-struct-compiler --prefix PATH : ${lib.makeBinPath [ jdk ]}
  '';

  meta = with lib; {
    homepage = "https://github.com/kaitai-io/kaitai_struct_compiler";
    description = "Compiler to generate binary data parsers in many languages";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ qubasa ];
    platforms = platforms.unix;
  };
}
