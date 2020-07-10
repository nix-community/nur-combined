{ lib
, stdenv
, fetchFromGitHub
, instantASSIST
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
    rev = "ade1148cd26c272cb569f9a4c10337f5a4e91f29";
    sha256 = "1207ihwxss7v3wz4xcvg21p10a8yz1r9phzb4n43138jpaynziqx";
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
      --subst-var-by instantASSIST "${instantASSIST}" \
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
    homepage = "https://github.com/instantOS/IinstantData";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
