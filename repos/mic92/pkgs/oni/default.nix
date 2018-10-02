{ stdenv, fetchurl, autoPatchelfHook, gtk3, nss, alsaLib, xlibs, gnome2 }: 

stdenv.mkDerivation rec {
  name = "oni";
  version = "0.3.6";

  src = fetchurl {
    url = "https://github.com/onivim/oni/releases/download/v${version}/Oni-${version}-x64-linux.tar.gz";
    sha256 = "06v13f3421nax6jzaxh330399isiw47vplmhaiqm15svf51drd9j";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/oni}
    cp -r * $out/share/oni
    ln -s $out/share/oni/oni $out/bin/oni
    runHook postInstall
    set -x
  '';

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    gtk3 stdenv.cc.cc nss alsaLib gnome2.GConf
  ] ++ (with xlibs; [
    xlibs.libXScrnSaver
    xlibs.libXtst
    xlibs.libxkbfile
  ]);

  meta = with stdenv.lib; {
    description = "An IDE built around Neovim";
    homepage = https://github.com/onivim/oni;
    license = licenses.mit;
    broken = true; # crashes on start at the moment
  };
}
