{ lib
, stdenv
, clblast
, fetchFromGitHub
, openblas
, ocl-icd
, python3
, supportCublas ? false
, cudatoolkit
}:
let
  version = "1.50.1";
  hash = "sha256-5BfCMadpkVsuCzhyKzN+yyHnfEEwV+J6VHPBpD3cBuY=";
  python = python3.withPackages (ps: with ps; [
    numpy
    sentencepiece
  ]);
in
stdenv.mkDerivation {
  pname = "koboldcpp";
  inherit version;
  src = fetchFromGitHub {
    repo = "koboldcpp";
    owner = "LostRuins";
    rev = "v" + version;
    inherit hash;
  };
  # src = ./koboldcpp;
  buildInputs = [ clblast openblas ocl-icd ]
    ++ lib.optional supportCublas cudatoolkit;
  makeFlags =
    lib.optional supportCublas "LLAMA_CUBLAS=1" ++
    [ "LLAMA_OPENBLAS=1" "LLAMA_CLBLAST=1" "default" "tools" ];
  installPhase = ''
    mkdir -p $out/bin
    mv *.so *.embd quantize_* $out/bin

    for f in koboldcpp convert
    do
      echo '#!${python}/bin/python' > $out/bin/$f
      cat $f.py >> $out/bin/$f
      chmod +x $out/bin/$f
    done
  '';
  NIX_CFLAGS_COMPILE = "-march=haswell";
}
