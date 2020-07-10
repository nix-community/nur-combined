{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {

  pname = "rangerplugins";
  version = "unstable";

  srcs = [ 
    (fetchFromGitHub {
      owner = "alexanderjeurissen";
      repo = "ranger_devicons";
      rev = "86a0810e744d33278d5dd74f57336c066a806c9d";
      sha256 = "0vhnvmcv5qq8hnxpzvq47cls0pax84ar9rzw9pxzliabfs6fy3g2";
      name = "ranger_devicons";
    })
    (fetchFromGitHub {
      owner = "laggardkernel";
      repo = "ranger-fzf-marks";
      rev = "79106fd6d9b98966e2683a52d35c25858ecb084a";
      sha256 = "0cz44lvbmn7jgw3p8slvkhmgfsnzcwky25j67ayp6igkv62wg79z";
      name = "ranger-fzf-marks";
    })
  ];

  sourceRoot = ".";
 
  installPhase = ''
    cleanPlugin () {
      mv $1/*.py .
      rm -rf "$1"
      mkdir "$1"
      mv *.py "$1"
    }
    cleanPlugin ranger-fzf-marks
    cleanPlugin ranger_devicons
    mkdir -p $out/share/rangerplugins
    touch $out/share/rangerplugins/__init__.py
    mv * $out/share/rangerplugins
    mv $out/share/rangerplugins/ranger_devicons/* $out/share/rangerplugins
  '';

  meta = with lib; {
    description = "instantOS rangerplugins";
    license = licenses.mit;
    homepage = "https://github.com/paperbenni/dotfiles";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
