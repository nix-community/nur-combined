{ lib
, stdenv
, fetchFromGitHub
, perl

, python3

## lsp
, lesspass-cli

## Open documentation deps
, eom, surf, zathura, coreutils, findutils, gawk

## Autotype
, wmctrl

## Sync databases deps
, merge-keepass
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
      rev = "334ba0752f18ea5ff40b746aa5a19691e13f7831";
      sha256 = "sha256-D5Rh/hX0smj0fkE7EKtjgoR4tD5qDat3LyWB0goi8Wc=";
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
    python3
    coreutils findutils gawk eom surf zathura 
    wmctrl
     merge-keepass
    perlEnv
  ];

  postPatch = ''
    substituteInPlace scripts/autotype.sh \
      --replace wmctrl ${wmctrl}/bin/wmctrl
    substituteInPlace scripts/scripts.desktop \
      --replace @Scripts@ $out \
      --replace "Exec=surf" "Exec=${surf}/bin/surf"
    mv pdf-inverter/invert.perl pdf-inverter/src

    echo "#! ${perlEnv}/bin/perl" > pdf-inverter/invert.perl
    echo "" >> pdf-inverter/invert.perl
    cat pdf-inverter/src >> pdf-inverter/invert.perl

    cat ${./lsp.sh} > lsp.sh
    substituteInPlace lsp.sh \
      --subst-var-by lesspass ${lesspass-cli}
  '';

  installPhase = ''
    # Install CleanMusic script
    install -Dm 555 scripts/CleanMusics.sh $out/bin/CleanMusics.sh

    # Install Open Documentation script
    install -Dm 555 lsp.sh $out/bin/lsp
    install -Dm 555 scripts/autotype.sh $out/bin/autotype
    install -Dm 555 scripts/open-documentation.py $out/bin/open-documentation.py
    install -Dm 555 pdf-inverter/invert.perl $out/bin/pdf-invert.pl
    install -Dm 555 scripts/scripts.desktop $out/share/applications/scripts.desktop
    install -Dm 644 scripts/icons/16-app-icon.png $out/share/icons/hicolor/16x16/apps/scripts.png
    install -Dm 644 scripts/icons/22-app-icon.png $out/share/icons/hicolor/22x22/apps/scripts.png
    install -Dm 644 scripts/icons/32-app-icon.png $out/share/icons/hicolor/32x32/apps/scripts.png
    install -Dm 644 scripts/icons/app-icon.svgz $out/share/icons/hicolor/scalable/apps/scripts.svgz

    # Install Synchronize Databases script
    #ln -s {sync-database}/bin/sync_database $out/bin/sync_database
  '';

  meta = with lib; {
    description = "Scripts to make my life easier";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/Scripts";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
