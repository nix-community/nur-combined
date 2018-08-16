{ stdenv, fetchFromGitHub, bc, coreutils, gawk, networkmanager, rofi, wirelesstools, makeWrapper }:

stdenv.mkDerivation rec {
  version = "1.0.0";
  baseName = "rofi-wifi-menu";
  name = "${baseName}-${version}";

  src = fetchFromGitHub {
    owner = "zbaylin";
    repo = "rofi-wifi-menu";
    rev = "a75bbaffffeb53bff5a8ef523e6b9ad128466f07";
    sha256 = "1cj9ypc5z881wi7rf6rn5bcz81cfd3z6ypnh7sjlrbb53zk1ijka";
  };

  buildInputs = [ makeWrapper ];
  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin

    cp -a $src/rofi-wifi-menu.sh $out/bin/${baseName}
    chmod a+x $out/bin/${baseName}

    mkdir -p $out/share/doc/${baseName}/
    cp -a $src/config.example $out/share/doc/${baseName}/config.example
  '';

  wrapperPath = with stdenv.lib; makeBinPath [
    bc
    coreutils
    gawk
    networkmanager
    rofi
    wirelesstools
  ];

  fixupPhase = ''
    patchShebangs $out/bin
    wrapProgram $out/bin/${baseName} --prefix PATH : "${wrapperPath}"
  '';

  meta = with stdenv.lib; {
    description = "A rofi wifi control panel";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
