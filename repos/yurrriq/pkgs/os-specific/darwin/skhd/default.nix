{ stdenv, fetchFromGitHub, Carbon, CoreAudio, CoreFoundation, cf-private }:

stdenv.mkDerivation rec {
  name = "skhd-${version}";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "skhd";
    rev = "v${version}";
    sha256 = "0y14a3zfxz02vsai9bmf0021xv0h78ns6r2w6ccpy1p18vdph8qh";
  };

  OTHER_LDFLAGS = "-framework CoreFoundation";

  buildInputs = [ Carbon CoreAudio CoreFoundation cf-private ];

  makeFlags = [ "BUILD_PATH=$(out)/bin" ];

  postInstall = ''
    mkdir -p $out/Library/LaunchDaemons
    cp ${./org.nixos.skhd.plist} $out/Library/LaunchDaemons/org.nixos.skhd.plist
    substituteInPlace $out/Library/LaunchDaemons/org.nixos.skhd.plist --subst-var out
  '';

  meta = with stdenv.lib; {
    description = "Simple hotkey daemon for macOS";
    homepage = https://github.com/koekeishiya/skhd;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ lnl7 periklis rvolosatovs yurrriq ];
    license = licenses.mit;
  };
}
