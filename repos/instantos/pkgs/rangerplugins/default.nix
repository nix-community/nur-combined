{ lib
, stdenv
, fetchurl
}:
stdenv.mkDerivation rec {

  pname = "rangerplugins";
  version = "unstable";

  srcs = [ 
    (fetchurl {
      url = "https://github.com/alexanderjeurissen/ranger_devicons/archive/main.tar.gz";
      sha256 = "1hsnk05128fapd4wvv9jij8cd614swzfkbf1j1snly6mz63ljdpj";
    })
    (fetchurl {
      url = "https://github.com/laggardkernel/ranger-fzf-marks/archive/master.tar.gz";
      sha256 = "1z4pcwm3is5fphr3wcj82ipvy1id667rycww62pg9cdd0fa7crjg";
    })
  ];
  
  postUnpack = ''
    mv ranger-fzf-marks-master ranger-fzf-marks
    mv ranger_devicons-main ranger_devicons
  '';

  sourceRoot = ".";
 
  installPhase = ''
    # mkdir -p $out/share/instantdotfiles
    # install -Dm 555 instantdotfiles $out/bin/instantdotfiles
    # rm instantdotfiles
    # mv * $out/share/instantdotfiles
    # echo "6081b26" > $out/share/instantdotfiles/versionhash

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
    ls -lh
  '';

  meta = with lib; {
    description = "InstantOS rangerplugins";
    license = licenses.mit;
    homepage = "https://github.com/paperbenni/dotfiles";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
