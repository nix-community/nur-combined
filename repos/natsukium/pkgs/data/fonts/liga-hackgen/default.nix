{
  lib,
  stdenv,
  pkgs,
}: let
  hackgen = pkgs.callPackage ../hackgen {};
  ligaturizer = pkgs.callPackage ../../../ligaturizer {};
in
  stdenv.mkDerivation rec {
    pname = "liga-hackgen-font";
    version = "0.0.1";
    src = "${hackgen}/share/fonts/hackgen";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/liga-hackgen
      for font in $(ls $src); do
        ${ligaturizer}/bin/ligaturizer $src/$font --output-dir=$out/share/fonts/liga-hackgen --prefix="Liga"
      done

      runHook postInstall
    '';

    phases = ["installPhase"];

    meta = with lib; {
      description = "Ligaturized hackgen with fira code";
      platforms = platforms.unix;
    };
  }
