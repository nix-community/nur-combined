{ stdenv, fetchurl, autoPatchelfHook, libGL, libGLU, alsaLib, makeWrapper }:

# TODO:
# mkdir -p ~/.etlegacy/etmain
# cp ${pkgs.enemyterritory}/etmain/pak*.pk3 ~/.etlegacy/etmain/

stdenv.mkDerivation rec {
  name = "etlegacy";
  version = "2.76";

  src = fetchurl {
    url = "https://www.etlegacy.com/download/file/122";
    sha256 = "097xazrmzd86a634cdw0ywgl7i3h1x8k6zqs823ccrgnqiyq9r4l";
  };

  buildInputs = [ stdenv.cc.cc.lib libGL libGLU alsaLib ];

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    mkdir -p $out/share $out/bin
    cp -r etlegacy-v${version}-i386/* $out/share/
    mv $out/share/{etl,etlded} $out/bin/

    # NixOS fails to build if this file is present (we're building 32-bit here).
    rm $out/share/legacy/omni-bot/omnibot_et.x86_64.so

    wrapProgram "$out/bin/etl" \
      --run "cd $out/share" \
      --set LD_LIBRARY_PATH "${stdenv.lib.makeLibraryPath [ alsaLib ]}"

    wrapProgram "$out/bin/etlded" \
      --run "cd $out/share"
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.etlegacy.com/";
    description = "Open source project that aims to create a fully compatible client and server for the popular online FPS game Wolfenstein: Enemy Territory";
    platforms = platforms.linux;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
