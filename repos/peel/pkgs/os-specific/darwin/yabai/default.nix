{ stdenv, fetchFromGitHub, Carbon, Cocoa, ScriptingBridge }:

stdenv.mkDerivation rec {
  name = "yabai-${version}";
  version = "2.0.1";
  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "yabai";
    rev = "v${version}";
    sha256 = "0vr3ivbqn1xc4x1r9x73dappqsxim3n0snz82mcshnp5sng4vf9m";
  };

  installPhase = ''
    mkdir -p $out/bin
    make install
    cp bin/* $out/bin/
    mkdir -p $out/share/man/man1
    cp doc/yabai.1 $out/share/man/man1/yabai.1
  '';
  buildInputs = [ Carbon Cocoa ScriptingBridge ];

  meta = with stdenv.lib; {
    description = "Tiling window manager for macOS based on plugin architecture";
    homepage = https://github.com/koekeishiya/yabai;
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
