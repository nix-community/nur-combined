{ lib, stdenvNoCC, fetchFromGitHub, gtk-engine-murrine }:

let base-name = "everforest-gtk";
in stdenvNoCC.mkDerivation {
  pname = "${base-name}-unstable";
  version = "2021-09-28";

  src = fetchFromGitHub {
    owner = "Theory-of-Everything";
    repo = base-name;
    rev = "03b18092320143868d0a215892986366ea7fd5ca";
    sha256 = "07nnb1hid5xl1khjakb5irj6fvxwvar2n8ziv92nch68bbia6vnz";
  };

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/${base-name}
    cp -a {assets,cinnamon,gtk-2.0,gtk-3.0,gtk-3.20,index.theme,metacity-1,openbox-3,unity,xfwm4} $out/share/themes/${base-name}
    runHook postInstall
  '';

  meta = with lib; {
    description = "The everforest colorscheme brought to gtk";
    homepage = "https://github.com/Theory-of-Everything/everforest-gtk";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
