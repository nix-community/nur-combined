{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "kwin-move-window";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Merrit";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FF6K7vcov+f93PQQEqzIkg8Nxwa9H3oWEZID2BHFwpU=";
  };

  installPhase = ''
    echo $PWD
    ls -la
    outdir=$out/share/kwin/scripts/movewindow
    mkdir -p $outdir
    cp -r contents metadata.json $outdir
  '';

  meta = with lib; {
    description = "KWin script that adds shortcuts to move the active window with the keyboard";
    homepage = "https://github.com/Merrit/kwin-move-window";
    platforms = platforms.linux ++ platforms.freebsd;
  };
}
