{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "mcsleepingserver";
  version = "1.6.0";

  src = fetchurl {
    url = "https://github.com/vincss/mcsleepingserverstarter/releases/download/v1.6.0/mcsleepingserverstarter-linux-x64";
    sha256 = "svTabsoRpksLNIkC0gC6QczE+rLd8QdK08UpXG8ufKA=";
  };

  sourceRoot = ".";

  unpackPhase = ":";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -m755 -D ${src} $out/bin/mcsleepingserverstarter-linux-x64
  '';

  preFixup = let
    libPath = lib.makeLibraryPath [
      stdenv.cc.cc.lib
    ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/mcsleepingserverstarter-linux-x64
  '';

  meta = with lib; {
    homepage = "https://github.com/vincss/mcsleepingserverstarter";
    description = "Put your minecraft server to rest, while SleepingServerStarter is watching !";
    platforms = platforms.unix;
    license = licenses.mit;
    maintainers = with maintainers; [ moaxcp ];
  };
}
