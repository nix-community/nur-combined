{ lib
, stdenv
, fetchFromGitHub
, perl

, python38

## Open documentation deps
, eom, surf, zathura, coreutils, findutils, gawk

## Sync databases deps
, sync-database, buildPythonPackage, parallel-ssh, merge-keepass
}:
let
  perlEnv = perl.withPackages(pp: with pp; [ PDFAPI2 ]);
in
stdenv.mkDerivation rec {

  pname = "Scripts";
  version = "unstable";

  srcs = [
    (fetchFromGitHub {
      owner = "SCOTT-HAMILTON";
      repo = "Scripts";
      rev = "c32e16e5df1f23f9765cd9a516a5a1f835d9387c";
      sha256 = "1qc95hkn7rli09g0icnv9j7f1rpcwi1j8pb0w5sx2bx79yvshp76";
      name = "scripts";
    })
    (fetchFromGitHub {
      owner = "egodat";
      repo = "pdf_inverter_perl";
      rev = "d5bc69623af89b47cc4469ba894627171d65c072";
      sha256 = "124l80cw84g6b70a84vb4ggynl45p0pvj1rx0mrbp6fkjdrrbbap";
      name = "pdf-inverter";
    })
  ];

  sourceRoot = ".";

  propagatedBuildInputs = [
    python38
    coreutils findutils gawk eom surf zathura 
    sync-database merge-keepass parallel-ssh
    perlEnv
  ];

  postPatch = ''
    substituteInPlace scripts/scripts.desktop \
      --replace @Scripts@ $out \
      --replace "Exec=surf" "Exec=${surf}/bin/surf"
    mv pdf-inverter/invert.perl pdf-inverter/src

    echo "#! ${perlEnv}/bin/perl" > pdf-inverter/invert.perl
    echo "" >> pdf-inverter/invert.perl
    cat pdf-inverter/src >> pdf-inverter/invert.perl
  '';

  installPhase = ''
    # Install CleanMusic script
    install -Dm 555 scripts/CleanMusics.sh $out/bin/CleanMusics.sh

    # Install Open Documentation script
    install -Dm 555 scripts/open-documentation.py $out/bin/open-documentation.py
    install -Dm 555 pdf-inverter/invert.perl $out/bin/pdf-invert.pl
    install -Dm 555 scripts/scripts.desktop $out/share/applications/scripts.desktop
    install -Dm 644 scripts/icons/16-app-icon.png $out/share/icons/hicolor/16x16/apps/scripts.png
    install -Dm 644 scripts/icons/22-app-icon.png $out/share/icons/hicolor/22x22/apps/scripts.png
    install -Dm 644 scripts/icons/32-app-icon.png $out/share/icons/hicolor/32x32/apps/scripts.png
    install -Dm 644 scripts/icons/app-icon.svgz $out/share/icons/hicolor/scalable/apps/scripts.svgz

    # Install Synchronize Databases script
    ln -s ${sync-database}/bin/sync_database $out/bin/sync_database
  '';

  meta = with lib; {
    description = "Scripts to make my life easier";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/Scripts";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
