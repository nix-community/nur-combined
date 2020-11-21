{ mkDerivation, fetchFromGitHub, base, stdenv, turtle, pywal, betterlockscreen }:
mkDerivation rec {
  pname = "er-wallpaper";
  version = "0.2.0.0";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = "0.2.0.0";
    sha256 = "11bi3850cl3k4c9rc4k924dzx220g5zfd81mg68jrws8jrf4vxfm";
  };

  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base turtle ];
  homepage = "https://github.com/emmanuelrosa/er-wallpaper";
  description = "A script for changing wallpaper and setting color schemes, for Linux";
  license = stdenv.lib.licenses.mit;

  postConfigure = ''
    substituteInPlace Main.hs \
      --replace _ER_PATH_WAL_ \""${pywal}/bin/wal"\" \
      --replace _ER_PATH_BETTERLOCKSCREEN_ \""${betterlockscreen}/bin/betterlockscreen"\"
  '';
}
