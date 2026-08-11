{
  pkgs,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "inotify-consumers";
  version = "1.0.0";

  #src = ./inotify-consumers;

  nativeBuildInputs = [ pkgs.bash ];

  dontUnpack = true;

  doCheck = false;

  installPhase = ''
    install -Dm755 ${./inotify-consumers} $out/bin/inotify-consumers
  '';

  meta = with lib; {
    description = "Get the procs sorted by the number of inotify watches";
    homepage = "https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers";
    license = licenses.publicDomain;
    platforms = lib.platforms.linux;
  };
}
