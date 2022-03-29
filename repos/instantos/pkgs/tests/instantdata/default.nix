{ lib
, stdenvNoCC
, instantdata
, file
}:
stdenvNoCC.mkDerivation {

  pname = "instantdata-test";
  version = "unstable";

  src = null;
  dontUnpack = true;
  
  nativeBuildInputs = [ file ];
  buildInputs = [ instantdata ];
  
  buildPhase = ''
    runHook preBuild
    echo "Checking instantdata : ${instantdata}/bin/instantdata"
    check () {
      file "$(instantdata "$1")$2" | grep "$3"
    }
    echo "Checking instantassist..."
    check --get-assist-dir /bin/instantassist ASCII

    echo "Checking instantconf..."
    check --get-conf-dir /bin/instantconf ASCII

    echo "Checking instantdotfiles..."
    check --get-dotfiles-dir /share/instantdotfiles/rootinstall.sh ASCII

    echo "Checking instantlogo..."
    check --get-logo-dir /share/backgrounds/readme.jpg JPEG

    echo "Checking instantmenu..."
    check --get-menu-dir /bin/instantmenu ELF

    echo "Checking instantshell..."
    check --get-shell-dir /bin/instantshell ASCII

    echo "Checking instantthemes..."
    check --get-themes-dir /bin/instantthemes ASCII

    echo "Checking instantutils..."
    check --get-utils-dir /bin/instantutils ASCII

    echo "Checking instantwallpapers..."
    check --get-wallpaper-dir /bin/instantwallpaper ASCII

    echo "Checking instantwidgets arrow png..."
    check --get-widgets-dir /share/instantwidgets/arrow.png image

    echo "Checking instantwm..."
    check --get-wm-dir /bin/instantwm ELF

    echo "Checking rangerplugins..."
    check --get-rangerplugins-dir /share/rangerplugins/devicons.py Python

    runHook postBuild
  '';

  installPhase = ''
    echo done > $out
  '';


  meta = with lib; {
    description = "instantOS Data test script";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/IinstantData";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
