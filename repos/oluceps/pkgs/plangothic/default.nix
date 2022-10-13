{ fetchFromGitHub
, stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "plangothic-font";
  version = "0.5.5694";
  #srcs = [
  #    (fetchurl {
  #      url = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic/releases/download/V0.5.5694/PlangothicP2-Regular.ttf";
  #      sha256 = "sha256-if/3PvZrOGoGT56cPNblrXORh8frEx8pQ6G0kDRuc9Y=";
  #      name = pname;
  #    })
  #
  #    (fetchurl {
  #      url = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic/releases/download/V0.5.5694/PlangothicP1-Regular.fallback.ttf";
  #      sha256 = "sha256-ELEyg+Lid+XtKasVk/Gp9VK2TZK8zOrCoUYXT23tRKk=";
  #      name = "src1";
  #    })
  #  ];
  src = fetchFromGitHub {
    owner = "Fitzgerald-Porthmouth-Koenigsegg";
    repo = "Plangothic";
    rev = "04e0c9ea86a0daaf8be7a8d8aacfd1dc127b22ce";
    fetchSubmodules = false;
    sha256 = "sha256-7/WObo/gLGc/1+RznR1mSZmhtO5CfcTiu6oOnPjaGx8=";
  };


  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp *.ttf $out/share/fonts/truetype/
  '';
  
  
  meta = with lib; {
    homepage = "https://github.com/welai/glow-sans";
    description = ''
      SHSans-derived CJK font family with a more concise & modern look
    '';
    license = with licenses;[ mit ofl ];
    platforms = platforms.all;
#    maintainers = with maintainers; [ oluceps ];
  };

  #    find . -name  '*.ttf'    -exec install -Dt $out/share/fonts/truetype {} \;
}

