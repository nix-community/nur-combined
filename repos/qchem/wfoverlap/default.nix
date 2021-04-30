{ stdenv, lib, fetchFromGitHub, gfortran, blas-i8, lapack-i8 }:
assert
  lib.asserts.assertMsg
  (blas-i8.isILP64 || blas-i8.passthru.implementation == "mkl")
  "64 bit integer BLAS implementation required.";

assert
  lib.asserts.assertMsg
  (lapack-i8.isILP64)
  "64 bit integer LAPACK implementation required.";

stdenv.mkDerivation rec {
    pname = "wfoverlap";
    version = "24.08.2020";

    src =
      let
        repo = fetchFromGitHub {
          owner = "sharc-md";
          repo = "sharc";
          rev = "d943ec7aff0fb6c81f61d3c057b0921d053e9e20";
          sha256 = "1a9frnxvm1jg4cv3jd4lm3q8m7igyc7fsp3baydfjkvk0b4ss9bc";
        };
      in "${repo}/wfoverlap/source";

    nativeBuildInputs = [ gfortran ];

    buildInputs = [
      gfortran
      blas-i8
      lapack-i8
    ];

    patches = [ ./Makefile.patch ];

    dontConfigure = true;

    hardeningDisable = [ "format" ];

    installPhase = ''
      mkdir -p $out/bin
      cp wfoverlap.x $out/bin/.
    '';

    meta = with lib; {
      description = "Efficient calculation of wavefunction overlaps";
      license = licenses.gpl3Only;
      homepage = "https://sharc-md.org/?page_id=309";
      platforms = platforms.linux;
    };
  }
