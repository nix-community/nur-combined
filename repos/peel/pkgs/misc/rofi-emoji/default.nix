{ stdenv, fetchurl, coreutils, curl, emojione, rofi, xsel, xdotool, xclip, libxml2, libnotify, makeWrapper }:

stdenv.mkDerivation rec {
  version = "1.0.0";
  baseName = "rofi-emoji";
  name = "${baseName}-${version}";

  src = fetchurl {
    sha256 = "0k8zy21j7nax3zd2sl8ac3q18hz65ixw0dy5s0wqwn11vdpmz9hn";
    url = "https://gist.githubusercontent.com/NearHuscarl/5d366e1a3b788814bcbea62c1f66241d/raw/f9bf1d143ef7ef8d3e2cb8ce2c7c4174ba6ab6b3/rofi-emoji.sh";
  };

  buildInputs = [ makeWrapper xdotool ];
  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${baseName}
    chmod a+x $out/bin/${baseName}
  '';

  wrapperPath = with stdenv.lib; makeBinPath [
    coreutils
    curl
    emojione
    libnotify
    libxml2
    rofi
    xclip
    xdotool
  ];

  fixupPhase = ''
    patchShebangs $out/bin
    wrapProgram $out/bin/${baseName} --prefix PATH : "${wrapperPath}"
  '';

  meta = with stdenv.lib; {
    description = "A rofi emoji picker";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
