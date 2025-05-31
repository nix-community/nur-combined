{
  fetchFromBitbucket,
  lib,
  makeWrapper,
  stdenv,
  python311,
  cmake,
}: let
  python = python311.withPackages (ps: with ps; [pyparsing z3]);
  src =
    fetchFromBitbucket
    {
      owner = "abhishekudupa";
      repo = "eusolver";
      rev = "cedce0c159996cafb14367ed400314d86b4832ad";
      sha256 = "pZXFRbq1XKn6eALFKobwKbjW7JzYpQhR1RrP9cdkWbI=";
    };

  libeusolver = stdenv.mkDerivation {
    name = "libeusolver";
    version = "0-unstable-2020-06-15";
    inherit src;
    patches = [./libeusolver-darwin.patch];

    sourceRoot = "${src.name}/thirdparty/libeusolver";
    buildInputs = [cmake python311];
    installPhase = ''
      mkdir -p $out
      cp eusolver.py $out
      cp libeusolver.* $out
    '';
  };
in
  stdenv.mkDerivation rec {
    name = "eusolver";
    version = "0-unstable-2020-06-15";
    inherit src;
    patches = [./time.patch];

    nativeBuildInputs = [
      python
      libeusolver
      makeWrapper
      cmake
    ];
    dontUseCmakeConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      cp -r src $out/src
      cp -r benchmarks $out/benchmarks

      makeWrapper ${python}/bin/python $out/bin/eusolver \
        --argv0 "eusolver" \
        --add-flags $out/src/benchmarks.py \
        --prefix PYTHONPATH : ${libeusolver}
    '';

    meta = with lib; {
      description = "enumerative unification based solver";
      homepage = "https://bitbucket.org/abhishekudupa/eusolver";
      platforms = platforms.unix;
    };
  }
