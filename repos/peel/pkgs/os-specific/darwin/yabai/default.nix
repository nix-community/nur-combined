{ stdenv, fetchFromGitHub, Carbon, Cocoa, ScriptingBridge }:

stdenv.mkDerivation rec {
  name = "yabai-${version}";
  version = "git-20190603";
  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "yabai";
    rev = "4e1f43b924cbded5cb6a508ceb7cd9248beed47a";
    sha256 = "0310p54519d4c3905di57ndqiiwradi262cdj2r7v1a8vnhmfxxx";
  };

  installPhase = ''
    mkdir -p $out/bin
    make install
    cp bin/* $out/bin/
  '';
  buildInputs = [ Carbon Cocoa ScriptingBridge ];

  meta = with stdenv.lib; {
    description = "Tiling window manager for macOS based on plugin architecture";
    homepage = https://github.com/koekeishiya/yabai;
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
