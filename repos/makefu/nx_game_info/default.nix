{ lib, stdenv, fetchurl , mono , unzip
}:
stdenv.mkDerivation rec {
  pname = "NX_Game_Info";
  name = "${pname}-${version}";
  version = "0.7.1";

  src = fetchurl {
    url = "https://github.com/garoxas/NX_Game_Info/releases/download/v${version}/NX.Game.Info_${version}_cli.zip";
    sha256 = "179hkgraydm5hg5fcs1xwh07cx7rbcfwklfak83f0sl1pbya542h";
  };

  sourceRoot = ".";
  buildInputs = [ unzip ];
  buildPhase = ":";
  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp * $out/lib/
    cat > $out/bin/nxgameinfo_cli <<EOF
    ${mono}/bin/mono $out/lib/nxgameinfo_cli.exe "\$@"
    EOF
    chmod +x $out/bin/nxgameinfo_cli
  '';

  meta = {
    description = "Tool to read information from Nintendo Switch game files";
    homepage = https://github.com/garoxas/NX_Game_Info;
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
