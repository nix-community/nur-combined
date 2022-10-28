{
  lib,
  stdenv,
  pkgs,
}: let
  hackgen-nf = pkgs.callPackage ../hackgen-nf {};
  ligaturizer = pkgs.callPackage ../../../ligaturizer {};
in
  stdenv.mkDerivation rec {
    pname = "liga-hackgen-nf-font";
    version = "0.0.1";
    src = "${hackgen-nf}/share/fonts/hackgen-nf";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/liga-hackgen-nf
      for font in $(ls $src); do
        ${ligaturizer}/bin/ligaturizer $src/$font --output-dir=$out/share/fonts/liga-hackgen-nf --prefix="Liga"
      done

      runHook postInstall
    '';

    phases = ["installPhase"];

    meta = with lib; {
      description = "Ligaturized hackgen-nf with fira code";
      platforms = platforms.unix;
    };
  }
