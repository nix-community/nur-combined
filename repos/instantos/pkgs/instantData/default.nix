{ lib
, stdenv
, fetchFromGitHub
, instantAssist
, instantConf
, instantDotfiles
, instantLogo
, instantMenu
, instantShell
, instantThemes
, instantUtils
, instantWallpaper
, instantWidgets
, instantWm
, Paperbash
, rangerplugins
}:
stdenv.mkDerivation {

  pname = "instantData";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantData";
    rev = "6586ef068872ce6a41a5f87cfb3ad78dc173a507";
    sha256 = "04y266scl47hb973hn4s42vxl3nd4ljv7k57ipf1md6snivxmjr9";
  };

  propagatedBuildInputs = [
    instantDotfiles
    instantLogo
    instantMenu
    instantShell
    instantThemes
    instantUtils
    instantWallpaper
    instantWidgets
    instantWm
    Paperbash
    rangerplugins
  ];

  postPatch = ''
    substituteInPlace instantdata.sh \
      --subst-var-by instantASSIST "${instantAssist}" \
      --subst-var-by instantConf "${instantConf}" \
      --subst-var-by instantDotfiles "${instantDotfiles}" \
      --subst-var-by instantLOGO "${instantLogo}" \
      --subst-var-by instantMENU "${instantMenu}" \
      --subst-var-by instantShell "${instantShell}" \
      --subst-var-by instantTHEMES "${instantThemes}" \
      --subst-var-by instantUtils "${instantUtils}" \
      --subst-var-by instantWALLPAPER "${instantWallpaper}" \
      --subst-var-by instantWidgets "${instantWidgets}" \
      --subst-var-by instantWM "${instantWm}" \
      --subst-var-by Paperbash "${Paperbash}" \
      --subst-var-by rangerplugins "${rangerplugins}"
  '';

  installPhase = ''
    install -Dm 555 instantdata.sh $out/bin/instantdata
    # install -Dm 644 desktop/st-luke.desktop $out/share/applications/st-luke.desktop
  '';

  meta = with lib; {
    description = "instantOS Data";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/IinstantData";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
