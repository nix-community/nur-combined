{
  lib,
  stdenv,
  hackgen-font,
  nerdfont ? false,
  hackgen-nf-font,
  ligaturizer,
}: let
  ligaturizer' = ligaturizer.overrideAttrs (_: {
    patches = [./ligature.patch];
  });
  family =
    if nerdfont
    then "hackgen-nf"
    else "hackgen";
in
  stdenv.mkDerivation {
    pname = "liga-${family}-font";
    version = "0.1.0";
    src = "${
      if nerdfont
      then hackgen-nf-font
      else hackgen-font
    }/share/fonts/${family}";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/liga-${family}
      for font in $(ls $src); do
        ${ligaturizer'}/bin/ligaturizer $src/$font --output-dir=$out/share/fonts/liga-${family} --prefix="Liga"
      done

      runHook postInstall
    '';

    phases = ["installPhase"];

    meta = with lib; {
      description = "Ligaturized ${family} with fira code";
      homepage = "https://github.com/natsukium/nur-packages/tree/main/pkgs/data/fonts/liga-hackgen";
      license = licenses.ofl;
      platforms = platforms.unix;
    };
  }
