{ lib
, stdenv
, fetchFromGitHub
, instantdata
, file
}:
stdenv.mkDerivation {

  pname = "instantdata-test";
  version = "unstable";

  # src = fetchFromGitHub {
  #   owner = "SCOTT-HAMILTON";
  #   repo = "instantData";
  #   rev = "ade1148cd26c272cb569f9a4c10337f5a4e91f29";
  #   sha256 = "1207ihwxss7v3wz4xcvg21p10a8yz1r9phzb4n43138jpaynziqx";
  #   name = "instantOS_instantData";
  # };

  src = null;
  dontUnpack = true;
  
  nativeBuildInputs = [ file ];
  buildInputs = [ instantdata ];
  
  buildPhase = ''
    runHook preBuild
    check () {
      file "$(${instantdata}/bin/instantdata "$1")$2" | grep "$3"
    }
    ${instantdata}/bin/instantdata -a
    echo "Checking instantassist..."
    check -a /bin/instantassist ASCII

    echo "Checking instantconf..."
    check -c /bin/instantconf ASCII

    echo "Checking instantdotfiles..."
    check -d /bin/instantdotfiles ASCII

    echo "Checking instantlogo..."
    check -l /share/backgrounds/readme.jpg JPEG

    echo "Checking instantmenu..."
    check -m /bin/instantmenu ELF

    echo "Checking instantshell..."
    check -s /bin/instantshell ASCII

    echo "Checking instantthemes..."
    check -t /bin/instantthemes ASCII

    echo "Checking instantutils..."
    check -u /bin/instantutils ASCII

    echo "Checking instantwallpapers..."
    check -wa /bin/instantwallpaper ASCII

    echo "Checking instantwidgets arrow png..."
    check -wi /share/instantwidgets/arrow.png image

    echo "Checking instantwm..."
    check -wm /bin/instantwm ELF

    echo "Checking rangerplugins..."
    check -r /share/rangerplugins/devicons.py Python

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
