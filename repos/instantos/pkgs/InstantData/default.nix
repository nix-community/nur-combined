{ lib
, stdenv
, fetchFromGitHub
, InstantConf
, InstantDotfiles
, InstantLOGO
, InstantMENU
, InstantShell
, InstantTHEMES
, InstantUtils
, InstantWALLPAPER
, InstantWidgets
, InstantWM
, Paperbash
, rangerplugins
}:
stdenv.mkDerivation rec {

  pname = "InstantData";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "InstantData";
    rev = "master";
    sha256 = "08vxzvd5jxfxk98jh63h8rsn6mwsgxwskpfm8z0xiyqpshd1adsx";
  };

  propagatedBuildInputs = [
    InstantDotfiles
    InstantLOGO
    InstantMENU
    InstantShell
    InstantTHEMES
    InstantUtils
    InstantWALLPAPER
    InstantWidgets
    InstantWM
    Paperbash
    rangerplugins
  ];

  postPatch = ''
    substituteInPlace instantdata.sh \
      --subst-var-by InstantConf "${InstantConf}" \
      --subst-var-by InstantDotfiles "${InstantDotfiles}" \
      --subst-var-by InstantLOGO "${InstantLOGO}" \
      --subst-var-by InstantMENU "${InstantMENU}" \
      --subst-var-by InstantShell "${InstantShell}" \
      --subst-var-by InstantTHEMES "${InstantTHEMES}" \
      --subst-var-by InstantUtils "${InstantUtils}" \
      --subst-var-by InstantWALLPAPER "${InstantWALLPAPER}" \
      --subst-var-by InstantWidgets "${InstantWidgets}" \
      --subst-var-by InstantWM "${InstantWM}" \
      --subst-var-by Paperbash "${Paperbash}" \
      --subst-var-by rangerplugins "${rangerplugins}"
  '';
  
  installPhase = ''
    install -Dm 555 instantdata.sh $out/bin/instantdata
    # install -Dm 644 desktop/st-luke.desktop $out/share/applications/st-luke.desktop
  '';

  meta = with lib; {
    description = "InstantOS Data";
    license = licenses.mit;
    # homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
