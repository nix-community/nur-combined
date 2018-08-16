{cfg, stdenv, fetchFromGitHub, Carbon, Cocoa }:

stdenv.mkDerivation rec {
  name = "chunkwm-core-${cfg.version}";
  version = "${cfg.version}";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "chunkwm";
    rev = "v${cfg.version}";
    sha256 = "${cfg.sha256}";
  };

  buildInputs = [ Carbon Cocoa ];

  #HACKY way to get macOS' clang++
  prePatch = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -F/System/Library/Frameworks"
    substituteInPlace makefile \
      --replace clang++ /usr/bin/clang++
  '';

  buildPhase = ''
    PATH=$PATH:/System/Library/Frameworks make install
    clang $src/src/chunkc/chunkc.c -O2 -o ./bin/chunkc
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/* $out/bin/

    mkdir -p $out/Library/LaunchDaemons
    cp ${./org.nixos.chunkwm.plist} $out/Library/LaunchDaemons/org.nixos.chunkwm.plist
    substituteInPlace $out/Library/LaunchDaemons/org.nixos.chunkwm.plist --subst-var out
  '';

  meta = with stdenv.lib; {
    description = "A tiling window manager for macOS";
    homepage = https://github.com/koekeishiya/chunkwm;
    downloadPage = https://github.com/koekeishiya/chunkwm/releases;
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
