{
  stdenvNoCC,
  fetchurl,
  unzip,
  ...
}:

stdenvNoCC.mkDerivation {
  pname = "hk-grotesk";
  version = "0.1.0";
  src = fetchurl ({
    name = "hk-grotest.zip";
    url = "https://fonts.google.com/download?family=Hanken%20Grotesk";
    sha256 = "sha256-LxBWeLgThF/QI7kBFigILDCzxnzKEpQXdTg3hEnJpGc=";
  });

  setSourceRoot = "sourceRoot=`pwd`";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,truetype}/
    find . -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.ttc' -exec install -Dt $out/share/fonts/truetype {} \;
  '';
  meta = {
    description = "Hanken Grotesk";
    homepage = "https://fonts.google.com/specimen/Hanken+Grotesk";
  };
}
