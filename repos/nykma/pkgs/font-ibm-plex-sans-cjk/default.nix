{
  stdenvNoCC, fetchurl, unzip,
  lib,
  ...
}:
let
  pname = "font-ibm-plex-sans-cjk";
  version = "1.1.0";
  fontURL = lang: version: "https://github.com/IBM/plex/releases/download/%40ibm%2Fplex-sans-${lang}%40${version}/ibm-plex-sans-${lang}.zip";
  src= {
    sc = fetchurl {
      url = fontURL "sc" version;
      hash = "sha256-CqvXN8jvAgaJK5EsdZEBwQuGxiRL6Z8ua1fGkFxxaDc=";
    };
    tc = fetchurl {
      url = fontURL "tc" version;
      hash = "sha256-t5YA08kVX6BckCTrgc/i+92M0GhQPfr9eUBepXeqn+w=";
    };
    jp = fetchurl {
      url = fontURL "jp" version;
      hash = "sha256-lue4rwe1s4+tnFMcEYVFWcRzMrRd5+ZcRWcrVBXzzVU=";
    };
    kr = fetchurl {
      url = fontURL "kr" version;
      hash = "sha256-mDeADI5a7fQSN3Xh12evpILJgzIb0vxgbJhfQF0kVi4=";
    };
  };
  installScript = lang: ''
  unzip ${src.${lang}}
  install --mode 644 ibm-plex-sans-${lang}/fonts/complete/ttf/hinted/*.ttf $out/share/fonts/truetype
  '';
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  nativeBuildInputs = [ unzip ];
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype

    ${installScript "sc"}
    ${installScript "tc"}
    ${installScript "jp"}
    ${installScript "kr"}
    '';

  meta = with lib; {
    description = "The package of IBM’s typeface, IBM Plex (SC/TC/JP/KR variation)";
    homepage = "https://github.com/IBM/plex";
    license=  licenses.ofl;
  };
}
