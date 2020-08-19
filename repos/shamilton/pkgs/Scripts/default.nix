{ pkgs
, lib
, stdenv
, fetchFromGitHub

## Open documentation deps
, eom, surf, zathura, coreutils, findutils, gawk

## Sync databases deps
, sync-database, buildPythonPackage, parallel-ssh, merge-keepass
}:
stdenv.mkDerivation rec {

  pname = "Scripts";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Scripts";
    rev = "6ef955b774abacf21dfe46b240d5a485380228e2";
    sha256 = "067qggvp5mlnzpxvcm32jgxycikgp7bdmw3q29901cn54gi7jd32";
  };

  propagatedBuildInputs = [
    coreutils findutils gawk eom surf zathura 
    sync-database merge-keepass parallel-ssh
  ];

  postPatch = ''
    substituteInPlace scripts.desktop \
      --replace @Scripts@ $out \
      --replace "Exec=surf" "Exec=${surf}/bin/surf"
  '';

  installPhase = ''
    # Install CleanMusic script
    install -Dm 555 CleanMusics.sh $out/bin/CleanMusics.sh

    # Install Open Documentation script
    install -Dm 555 open-documentation.py $out/bin/open-documentation.py
    install -Dm 555 scripts.desktop $out/share/applications/scripts.desktop
    install -Dm 644 icons/16-app-icon.png $out/share/icons/hicolor/16x16/apps/scripts.png
    install -Dm 644 icons/22-app-icon.png $out/share/icons/hicolor/22x22/apps/scripts.png
    install -Dm 644 icons/32-app-icon.png $out/share/icons/hicolor/32x32/apps/scripts.png
    install -Dm 644 icons/app-icon.svgz $out/share/icons/hicolor/scalable/apps/scripts.svgz

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
