{ lib
, stdenv
, fetchFromGitHub
, instantConf
, instantDotfiles
, instantLOGO
, instantMENU
, instantShell
, instantTHEMES
, instantUtils
, instantWALLPAPER
, instantWidgets
, instantWM
, Paperbash
, rangerplugins
}:
stdenv.mkDerivation rec {

  pname = "instantData";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "instantData";
    rev = "a3f766506ca38f57eac0a0b702525f48c0ac8443";
    sha256 = "08vxzvd5jxfxk98jh63h8rsn6mwsgxwskpfm8z0xiyqpshd1adsx";
  };

  propagatedBuildInputs = [
    instantDotfiles
    instantLOGO
    instantMENU
    instantShell
    instantTHEMES
    instantUtils
    instantWALLPAPER
    instantWidgets
    instantWM
    Paperbash
    rangerplugins
  ];

  postPatch = ''
    substituteInPlace instantdata.sh \
      --subst-var-by instantConf "${instantConf}" \
      --subst-var-by instantDotfiles "${instantDotfiles}" \
      --subst-var-by instantLOGO "${instantLOGO}" \
      --subst-var-by instantMENU "${instantMENU}" \
      --subst-var-by instantShell "${instantShell}" \
      --subst-var-by instantTHEMES "${instantTHEMES}" \
      --subst-var-by instantUtils "${instantUtils}" \
      --subst-var-by instantWALLPAPER "${instantWALLPAPER}" \
      --subst-var-by instantWidgets "${instantWidgets}" \
      --subst-var-by instantWM "${instantWM}" \
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
    # homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
