{ lib
, stdenv
, fetchFromGitHub
, eom
, surf
, zathura
, coreutils
, findutils
, gawk
}:
stdenv.mkDerivation rec {

  pname = "Scripts";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Scripts";
    rev = "master";
    sha256 = "110k1zpa7h4sgdpchpp9003agair68fa0alv03qr3lpmiadzyyc6";
  };

  propagatedBuildInputs = [ coreutils findutils gawk eom surf zathura ];

  postPatch = ''
    ls -lh
    substituteInPlace scripts.desktop \
      --replace @Scripts@ $out
    cat scripts.desktop
  '';

  installPhase = ''
    install -Dm 555 CleanMusics.sh $out/bin/CleanMusics.sh
    install -Dm 555 open-documentation.py $out/bin/open-documentation.py
    install -Dm 555 scripts.desktop $out/share/applications/scripts.desktop
    install -Dm 644 icons/16-app-icon.png $out/share/icons/hicolor/16x16/apps/scripts.png
    install -Dm 644 icons/22-app-icon.png $out/share/icons/hicolor/22x22/apps/scripts.png
    install -Dm 644 icons/32-app-icon.png $out/share/icons/hicolor/32x32/apps/scripts.png
    install -Dm 644 icons/app-icon.svgz $out/share/icons/hicolor/scalable/apps/scripts.svgz
  '';

  meta = with lib; {
    description = "Scripts to make my life easier";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/Scripts";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
